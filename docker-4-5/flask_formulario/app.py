
from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
from flask_sqlalchemy import SQLAlchemy
import os

db = SQLAlchemy()

class Submission(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), nullable=False)

def create_app():
    app = Flask(__name__)
    app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("DATABASE_URL")
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    app.secret_key = 'pildorasdeprogramacion'
    
    db.init_app(app)
    
    with app.app_context():
        db.create_all()
    
    @app.route("/", methods=["GET", "POST"])
    def form():
        if request.method == "POST":
            name = request.form["name"]
            email = request.form["email"]
            submission = Submission(name=name, email=email)
            db.session.add(submission)
            db.session.commit()
            flash("¡Formulario enviado exitosamente!", "success")
            return redirect("/")
        return render_template("form.html")
    
    return app

if __name__ == "__main__":
    app = create_app()
    app.run(debug=True, host="0.0.0.0")