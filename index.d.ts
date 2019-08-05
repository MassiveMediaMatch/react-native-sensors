declare module "react-native-sensors" {
  import { Observable } from "rxjs";

  type Sensors = {
    accelerometer: "accelerometer";
    gyroscope: "gyroscope";
    magnetometer: "magnetometer";
    barometer: "barometer";
    rotationmeter: "rotationmeter";
  };

  export const SensorTypes: Sensors;

  export const setUpdateIntervalForType: (
    type: keyof Sensors,
    updateInterval: number
  ) => void;

  export interface SensorData {
    x: number;
    y: number;
    z: number;
    timestamp: string;
  }

  export interface BarometerData {
    pressure: number;
  }

  export interface RotationData {
    roll: number;
    pitch: number;
    azimut: number;
  }

  type SensorsBase = {
    accelerometer: Observable<SensorData>;
    gyroscope: Observable<SensorData>;
    magnetometer: Observable<SensorData>;
    barometer: Observable<BarometerData>;
    rotationmeter: Observable<RotationData>;
  };

  export const {
    accelerometer,
    gyroscope,
    magnetometer,
    barometer,
    rotationmeter
  }: SensorsBase;

  const sensors: SensorsBase;

  export default sensors;
}
