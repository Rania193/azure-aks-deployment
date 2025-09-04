from app.main import app
import os
from prometheus_flask_exporter import PrometheusMetrics
metrics = PrometheusMetrics(app)

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
