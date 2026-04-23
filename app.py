from flask import Flask, render_template, request, redirect, url_for, session
import psycopg2
import locale
from datetime import datetime

# 🔹 idioma fechas
try:
    locale.setlocale(locale.LC_TIME, 'es_ES.UTF-8')
except:
    locale.setlocale(locale.LC_TIME, 'Spanish_Spain')

app = Flask(__name__)
app.secret_key = "clave_secreta"

# 🔹 conexión BD
def get_connection():
    return psycopg2.connect(
        host="localhost",
        database="lcms01",
        user="postgres",
        password="1234"
    )

# 🔔 NOTIFICACIONES (SIN BD)
def agregar_notificacion(mensaje):
    if "notificaciones" not in session:
        session["notificaciones"] = []

    session["notificaciones"].insert(0, mensaje)

    # máximo 5
    session["notificaciones"] = session["notificaciones"][:5]

# 🔥 QUERY BASE
BASE_RECIBO_QUERY = """
    SELECT 
        r.id_recibo,
        r.fecha_ingreso,
        r.fecha_salida,
        r.valor_total,
        r.nombre_cliente,
        r.telefono_cliente,
        r.paquete,
        e.nombre
    FROM recibo r
    JOIN estado e ON r.id_estado = e.id_estado
"""

# ---------------- LOGIN ----------------
@app.route("/", methods=["GET", "POST"])
def login():

    if "usuario" in session:
        return redirect(url_for("index"))

    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]

        conn = get_connection()
        cur = conn.cursor()

        cur.execute(
            "SELECT username, password, rol FROM usuario WHERE username = %s",
            (username,)
        )
        user = cur.fetchone()

        cur.close()
        conn.close()

        if user and user[1] == password:
            session["usuario"] = user[0]
            session["rol"] = user[2]
            return redirect(url_for("index"))
        else:
            return render_template("login.html", error="Credenciales incorrectas")

    return render_template("login.html")

# VALIDACIÓN DE ESTADOS
def estado_valido(actual, nuevo):
    flujo = {
        "recibido": "en planta",
        "en planta": "listo",
        "listo": "entregado"
    }
    return flujo.get(actual) == nuevo

# PROTEGER RUTAS
def login_required():
    return "usuario" in session

# ---------------- RECIBOS ----------------
@app.route("/recibos")
def index():
    if not login_required():
        return redirect(url_for("login"))

    conn = get_connection()
    cur = conn.cursor()

    id_recibo = request.args.get("id_recibo")
    nombre = request.args.get("nombre")
    fecha = request.args.get("fecha")
    estado = request.args.get("estado")

    query = BASE_RECIBO_QUERY + " WHERE 1=1"
    params = []

    if id_recibo:
        query += " AND r.id_recibo = %s"
        params.append(id_recibo)

    if nombre:
        query += " AND LOWER(r.nombre_cliente) LIKE LOWER(%s)"
        params.append(f"%{nombre}%")

    if fecha:
        query += " AND DATE(r.fecha_ingreso) = %s"
        params.append(fecha)

    if estado:
        query += " AND e.nombre = %s"
        params.append(estado)

    query += " ORDER BY r.id_recibo;"

    cur.execute(query, params)
    recibos = cur.fetchall()

    cur.close()
    conn.close()

    return render_template(
        "recibos.html",
        recibos=recibos,
        rol=session["rol"],
        notificaciones=session.get("notificaciones", [])
    )

# ---------------- DETALLE ----------------
@app.route("/recibo/<int:id>")
def detalle_recibo(id):
    if not login_required():
        return redirect(url_for("login"))

    conn = get_connection()
    cur = conn.cursor()

    cur.execute(BASE_RECIBO_QUERY + " WHERE r.id_recibo = %s;", (id,))
    recibo = cur.fetchone()

    cur.execute("""
        SELECT 
            h.fecha_cambio,
            e1.nombre,
            e2.nombre
        FROM historial_recibo h
        LEFT JOIN estado e1 ON h.id_estado_anterior = e1.id_estado
        JOIN estado e2 ON h.id_estado_nuevo = e2.id_estado
        WHERE h.id_recibo = %s
        ORDER BY h.fecha_cambio DESC;
    """, (id,))

    historial = cur.fetchall()

    cur.close()
    conn.close()

    return render_template(
        "detalle_recibo.html",
        recibo=recibo,
        historial=historial,
        rol=session["rol"]
    )

# ---------------- ELIMINAR ----------------
@app.route("/recibo/<int:id>/eliminar", methods=["POST"])
def eliminar_recibo(id):
    if not login_required():
        return redirect(url_for("login"))

    conn = get_connection()
    cur = conn.cursor()

    cur.execute("DELETE FROM recibo WHERE id_recibo = %s;", (id,))

    conn.commit()
    cur.close()
    conn.close()

    agregar_notificacion(f"🗑️ Recibo #{id} eliminado")

    return redirect(url_for("index"))

# ---------------- ENTREGAR ----------------
@app.route("/recibo/<int:id>/entregar", methods=["POST"])
def entregar_recibo(id):
    if not login_required():
        return redirect(url_for("login"))

    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT e.nombre
        FROM recibo r
        JOIN estado e ON r.id_estado = e.id_estado
        WHERE r.id_recibo = %s;
    """, (id,))
    
    estado_actual = cur.fetchone()

    if not estado_actual:
        return redirect(url_for("index"))

    estado_actual = estado_actual[0].lower().strip()

    if estado_actual != "listo":

        cur.execute(BASE_RECIBO_QUERY + " WHERE r.id_recibo = %s;", (id,))
        recibo = cur.fetchone()

        cur.execute("""
            SELECT 
                h.fecha_cambio,
                e1.nombre,
                e2.nombre
            FROM historial_recibo h
            LEFT JOIN estado e1 ON h.id_estado_anterior = e1.id_estado
            JOIN estado e2 ON h.id_estado_nuevo = e2.id_estado
            WHERE h.id_recibo = %s
            ORDER BY h.fecha_cambio DESC;
        """, (id,))
        historial = cur.fetchall()

        cur.close()
        conn.close()

        return render_template(
            "detalle_recibo.html",
            recibo=recibo,
            historial=historial,
            rol=session["rol"],
            error="Solo puedes entregar prendas en estado 'listo'"
        )

    estado_entregado = 4

    cur.execute("""
        UPDATE recibo
        SET id_estado = %s
        WHERE id_recibo = %s;
    """, (estado_entregado, id))

    conn.commit()
    cur.close()
    conn.close()

    agregar_notificacion(f"📦 Recibo #{id} entregado")

    return redirect(url_for("detalle_recibo", id=id))

# ---------------- PLANTA ----------------
@app.route("/planta", methods=["GET", "POST"])
def planta():
    if not login_required():
        return redirect(url_for("login"))

    if session["rol"] != "admin":
        return "Acceso denegado", 403

    conn = get_connection()
    cur = conn.cursor()

    if request.method == "POST":

        tipo = request.form.get("tipo")
        ids = request.form.get("ids")

        if not ids:
            return render_template("planta.html", error="Debes ingresar IDs")

        try:
            lista_ids = [int(i.strip()) for i in ids.split(",")]
        except:
            return render_template("planta.html", error="Formato inválido")

        for rid in lista_ids:
            cur.execute("""
                SELECT e.nombre
                FROM recibo r
                JOIN estado e ON r.id_estado = e.id_estado
                WHERE r.id_recibo = %s;
            """, (rid,))
            
            resultado = cur.fetchone()

            if not resultado:
                return render_template("planta.html", error=f"Recibo {rid} no existe")

            actual = resultado[0].lower().strip()

            nuevo = "en planta" if tipo == "enviar" else "listo"

            if not estado_valido(actual, nuevo):
                return render_template(
                    "planta.html",
                    error=f"No puedes pasar el recibo {rid} de '{actual}' a '{nuevo}'"
                )

        estado = 2 if tipo == "enviar" else 3

        cur.execute("""
            UPDATE recibo
            SET id_estado = %s
            WHERE id_recibo = ANY(%s);
        """, (estado, lista_ids))

        conn.commit()
        cur.close()
        conn.close()

        if len(lista_ids) == 1:
            ids_texto = f"#{lista_ids[0]}"
        else:
            ids_texto = "#" + ", #".join(map(str, lista_ids))

        if tipo == "enviar":
            mensaje = f"🏭 Recibo(s) {ids_texto} enviado(s) a planta"
        else:
            mensaje = f"📤 Recibo(s) {ids_texto} listo(s) para entrega"

        agregar_notificacion(mensaje)

        return redirect(url_for("planta"))

    cur.close()
    conn.close()

    return render_template("planta.html")

# ---------------- NUEVO ----------------
@app.route("/nuevo", methods=["GET", "POST"])
def nuevo():
    if not login_required():
        return redirect(url_for("login"))

    conn = get_connection()
    cur = conn.cursor()

    if request.method == "POST":

        fecha_ingreso = request.form["fecha_ingreso"]
        fecha_salida = request.form["fecha_salida"]
        valor_total = request.form["valor_total"]
        nombre_cliente = request.form["nombre_cliente"]
        telefono = request.form["telefono_cliente"]
        paquete = request.form["paquete"]

        id_estado = 1

        if not all([fecha_ingreso, fecha_salida, valor_total, nombre_cliente, telefono, paquete]):
            return render_template("nuevo.html", error="Todos los campos son obligatorios")

        cur.execute("""
            INSERT INTO recibo 
            (fecha_ingreso, fecha_salida, valor_total, nombre_cliente, telefono_cliente, paquete, id_estado)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            RETURNING id_recibo;
        """, (
            fecha_ingreso,
            fecha_salida,
            int(valor_total),
            nombre_cliente,
            telefono,
            paquete,
            id_estado
        ))

        nuevo_id = cur.fetchone()[0]

        conn.commit()
        cur.close()
        conn.close()

        agregar_notificacion(f"📥 Recibo #{nuevo_id} registrado")

        return redirect(url_for("index"))

    return render_template("nuevo.html")

# ---------------- LOGOUT ----------------
@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))

if __name__ == "__main__":
    app.run(debug=True)