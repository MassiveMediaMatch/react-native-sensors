package com.sensors;

import android.os.Bundle;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.util.Log;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.modules.core.DeviceEventManagerModule;

public class Rotationmeter extends ReactContextBaseJavaModule implements SensorEventListener {

  private final ReactApplicationContext reactContext;
  private final SensorManager sensorManager;
  private final Sensor accelerometer;
  private final Sensor magnetometer;
  private double lastReading = (double) System.currentTimeMillis();
  private int interval;
  private Arguments arguments;

  public Rotationmeter(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
    this.sensorManager = (SensorManager)reactContext.getSystemService(reactContext.SENSOR_SERVICE);
    this.accelerometer = this.sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
    this.magnetometer = this.sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD);
  }

  // RN Methods
  @ReactMethod
  public void isAvailable(Promise promise) {
    if (this.accelerometer == null || this.magnetometer == null) {
      // No sensor found, throw error
      promise.reject(new RuntimeException("No Rotationmeter found"));
      return;
    }
    promise.resolve(null);
  }

  @ReactMethod
  public void setUpdateInterval(int newInterval) {
    this.interval = newInterval;
  }


  @ReactMethod
  public void startUpdates() {
    // Milisecond to Mikrosecond conversion
    sensorManager.registerListener(this, this.accelerometer, this.interval * 1000);
    sensorManager.registerListener(this, this.magnetometer, this.interval * 1000);
  }

  @ReactMethod
  public void stopUpdates() {
    sensorManager.unregisterListener(this);
  }

  @Override
  public String getName() {
    return "Rotationmeter";
  }

  // SensorEventListener Interface
  private void sendEvent(String eventName, @Nullable WritableMap params) {
    try {
      this.reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
        .emit(eventName, params);
    } catch (RuntimeException e) {
      Log.e("ERROR", "java.lang.RuntimeException: Trying to invoke Javascript before CatalystInstance has been set!");
    }
  }

  float[] mGravity;
  float[] mGeomagnetic;
  @Override
  public void onSensorChanged(SensorEvent sensorEvent) {
    if (sensorEvent.sensor.getType() == Sensor.TYPE_ACCELEROMETER)
      mGravity = sensorEvent.values;
    if (sensorEvent.sensor.getType() == Sensor.TYPE_MAGNETIC_FIELD)
      mGeomagnetic = sensorEvent.values;

    if (mGravity != null && mGeomagnetic != null) {
      float R[] = new float[9];
      float I[] = new float[9];
      boolean success = SensorManager.getRotationMatrix(R, I, mGravity, mGeomagnetic);
      if (success) {
        double tempMs = (double) System.currentTimeMillis();
        if (tempMs - lastReading >= interval){
          lastReading = tempMs;

          float orientation[] = new float[3];
          SensorManager.getOrientation(R, orientation);

          WritableMap map = arguments.createMap();

          map.putDouble("azimut", orientation[0]);
          map.putDouble("pitch", orientation[1]);
          map.putDouble("roll", orientation[2]);
          map.putDouble("timestamp", tempMs);
          sendEvent("Rotationmeter", map);
        }
      }
    }
  }

  @Override
  public void onAccuracyChanged(Sensor sensor, int accuracy) {
  }
}
