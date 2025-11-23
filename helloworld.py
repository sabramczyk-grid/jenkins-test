from flask import Flask

app = Flask(__name__)


@app.route('/')
def hello():
    return "Hello World from Jenkins, Terraform and Flask!"


if __name__ == "__main__":
    # 0.0.0.0 to make the server externally visible
    app.run(host='0.0.0.0', port=5000)
