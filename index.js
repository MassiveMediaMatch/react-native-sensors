import sensors from "./src/sensors";
export { setUpdateInterval as setUpdateIntervalForType } from "./src/rnsensors";

export const SensorTypes = {
  accelerometer: "accelerometer",
  gyroscope: "gyroscope",
  magnetometer: "magnetometer",
  barometer: "barometer",
  rotationmeter: "rotationmeter"
};

export const { accelerometer, gyroscope, magnetometer, barometer, rotationmeter } = sensors;
export default sensors;
