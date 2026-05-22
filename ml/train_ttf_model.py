import os
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error
import joblib
import logging

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

def generate_telemetry_data(samples=5000):
    """
    Simulates physical plumbing telemetry.
    Features: 
      - flow_variance: Fluctuations in water flow (indicates internal friction/scaling)
      - pressure_drops: Frequency of sudden micro-drops in pressure
      - pipe_age_years: Age of infrastructure
    Target:
      - time_to_failure_days: Estimated days until catastrophic rupture
    """
    np.random.seed(42)
    
    flow_variance = np.random.uniform(0.1, 15.0, samples)
    pressure_drops = np.random.randint(0, 50, samples)
    pipe_age_years = np.random.uniform(0.5, 30.0, samples)
    
    # Mathematical synthesis of Time To Failure based on features + noise
    # High variance, high pressure drops, and old pipes drastically reduce TTF
    base_life = 3650.0 # 10 years base expected life
    
    ttf = base_life - (flow_variance * 50) - (pressure_drops * 20) - (pipe_age_years * 100)
    # Ensure no negative TTF, add noise
    ttf = np.maximum(ttf + np.random.normal(0, 50, samples), 1.0)
    
    return pd.DataFrame({
        'flow_variance_lpm': flow_variance,
        'pressure_drop_events': pressure_drops,
        'pipe_age_years': pipe_age_years,
        'time_to_failure_days': ttf
    })

def main():
    logging.info("Initializing AquaForge AI Predictive Matrix...")
    df = generate_telemetry_data()
    
    X = df[['flow_variance_lpm', 'pressure_drop_events', 'pipe_age_years']]
    y = df['time_to_failure_days']
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    logging.info("Training RandomForestRegressor on historical telemetry...")
    model = RandomForestRegressor(n_estimators=100, max_depth=10, random_state=42)
    model.fit(X_train, y_train)
    
    predictions = model.predict(X_test)
    mse = mean_squared_error(y_test, predictions)
    rmse = np.sqrt(mse)
    
    logging.info(f"Model Training Complete. RMSE: {rmse:.2f} days")
    
    # Export Model
    os.makedirs('build', exist_ok=True)
    model_path = 'build/ttf_model.pkl'
    joblib.dump(model, model_path)
    logging.info(f"Physical Model exported to {model_path} - Ready for Cloud Deployment.")

if __name__ == "__main__":
    main()
