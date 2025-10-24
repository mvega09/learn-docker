from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
import requests
import os

app = Flask(__name__)
app.secret_key = 'pildorasdeprogramacion'

API_URL = os.getenv('API_URL', 'http://localhost:8000')
API_URL_BROWSER = os.getenv('API_URL_BROWSER', 'http://localhost:8000')

@app.route('/')
def index():
    return render_template('index.html', api_url=API_URL_BROWSER)

@app.route('/vote', methods=['POST'])
def vote():
    option = request.form.get('option')
    
    if not option:
        flash('Por favor selecciona una opción', 'error')
        return redirect(url_for('index'))
    
    try:
        response = requests.post(f'{API_URL}/vote', json={'option': option})
        
        if response.status_code == 200:
            flash(f'¡Gracias por votar por {option}!', 'success')
        else:
            flash('Error al procesar el voto', 'error')
            
    except requests.RequestException:
        flash('Error de conexión con el servidor', 'error')
    
    return redirect(url_for('index'))

@app.route('/results')
def results():
    try:
        response = requests.get(f'{API_URL}/results')
        if response.status_code == 200:
            return response.json()
        else:
            return {'error': 'Error al obtener resultados'}, 500
    except requests.RequestException:
        return {'error': 'Error de conexión'}, 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)