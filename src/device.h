/*!
 * This file is part of WatchFlower.
 * COPYRIGHT (C) 2019 Emeric Grange - All Rights Reserved
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * \date      2018
 * \author    Emeric Grange <emeric.grange@gmail.com>
 */

#ifndef DEVICE_H
#define DEVICE_H
/* ************************************************************************** */

#include <QObject>
#include <QList>
#include <QTimer>
#include <QDateTime>

#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

#include <QtCharts/QLineSeries>
#include <QtCharts/QDateTimeAxis>

#define LATEST_KNOWN_FIRMWARE_FLOWERCARE    "3.1.8"
#define LATEST_KNOWN_FIRMWARE_ROPOT         "1.1.5"
#define LATEST_KNOWN_FIRMWARE_HYGROTEMP     "00.00.66"

/* ************************************************************************** */

enum DeviceCapabilities {
    DEVICE_BATTERY           = (1 << 0), //!< Can report its battery level
    DEVICE_TEMPERATURE       = (1 << 1), //!< Has a temperature sensor
    DEVICE_HYGROMETRY        = (1 << 2), //!< Has a hygrometry (or humidity) sensor
    DEVICE_LUMINOSITY        = (1 << 3), //!< Has a luminosity sensor
    DEVICE_SOIL_MOISTURE     = (1 << 4), //!< Has a soil moisture sensor (can be associated to a plant)
    DEVICE_SOIL_CONDUCTIVITY = (1 << 5), //!< Has a conductivity/fertility sensor
};

/* ************************************************************************** */

/*!
 * \brief The Device class
 */
class Device: public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool connected READ isAvailable NOTIFY statusUpdated)
    Q_PROPERTY(bool available READ isAvailable NOTIFY statusUpdated)

    Q_PROPERTY(bool updating READ isUpdating NOTIFY statusUpdated)
    Q_PROPERTY(int lastUpdateMin READ getLastUpdateInt NOTIFY statusUpdated)
    Q_PROPERTY(QString lastUpdateStr READ getLastUpdateString NOTIFY statusUpdated)

    Q_PROPERTY(QString deviceName READ getName NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceAddress READ getAddress NOTIFY sensorUpdated)
    Q_PROPERTY(QString deviceLocationName READ getLocationName NOTIFY sensorUpdated)
    Q_PROPERTY(QString devicePlantName READ getPlantName NOTIFY sensorUpdated)

    Q_PROPERTY(QString deviceFirmware READ getFirmware NOTIFY sensorUpdated)
    Q_PROPERTY(bool deviceFirmwareUpToDate READ isFirmwareUpToDate NOTIFY sensorUpdated)
    Q_PROPERTY(int deviceBattery READ getBattery NOTIFY sensorUpdated)

    Q_PROPERTY(float deviceTemp READ getTemp NOTIFY datasUpdated)
    Q_PROPERTY(float deviceTempC READ getTempC NOTIFY datasUpdated)
    Q_PROPERTY(float deviceTempF READ getTempF NOTIFY datasUpdated)
    Q_PROPERTY(int deviceHygro READ getHygro NOTIFY datasUpdated)
    Q_PROPERTY(int deviceLuminosity READ getLuminosity NOTIFY datasUpdated)
    Q_PROPERTY(int deviceConductivity READ getConductivity NOTIFY datasUpdated)

    Q_PROPERTY(int limitHygroMin READ getLimitHygroMin WRITE setLimitHygroMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitHygroMax READ getLimitHygroMax WRITE setLimitHygroMax NOTIFY limitsUpdated)
    Q_PROPERTY(int limitTempMin READ getLimitTempMin WRITE setLimitTempMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitTempMax READ getLimitTempMax WRITE setLimitTempMax NOTIFY limitsUpdated)
    Q_PROPERTY(int limitLumiMin READ getLimitLumiMin WRITE setLimitLumiMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitLumiMax READ getLimitLumiMax WRITE setLimitLumiMax NOTIFY limitsUpdated)
    Q_PROPERTY(int limitConduMin READ getLimitConduMin WRITE setLimitConduMin NOTIFY limitsUpdated)
    Q_PROPERTY(int limitConduMax READ getLimitConduMax WRITE setLimitConduMax NOTIFY limitsUpdated)

Q_SIGNALS:
    void statusUpdated();
    void sensorUpdated();
    void datasUpdated();
    void limitsUpdated();

protected:
    QString m_deviceName;
    QString m_deviceAddress;
    QBluetoothDeviceInfo bleDevice;

    int m_capabilities = 0;

    bool m_available = false;
    bool m_updating = false;
    QDateTime m_lastUpdate;
    QTimer m_updateTimer;
    QTimer m_timeoutTimer;

    // BLE device infos
    QString m_firmware = "UNKN";
    bool m_firmware_uptodate = false;
    int m_battery = -1;

    // BLE device datas
    float m_temp = -111.f;
    int m_hygro = -1;
    int m_luminosity = -1;
    int m_conductivity = -1;

    // BLE associated datas
    QString m_locationName;
    QString m_plantName;

    // BLE device limits
    int m_limitHygroMin = 15;
    int m_limitHygroMax = 50;
    int m_limitTempMin = 8;
    int m_limitTempMax = 32;
    int m_limitLumiMin = 3000;
    int m_limitLumiMax = 10000;
    int m_limitConduMin = 250;
    int m_limitConduMax = 1000;

    // BLE
    int m_timeout = 20;
    int m_retries = 2;
    int m_update_interval = 0;

    // QLowEnergyController related
    QLowEnergyController *controller = nullptr;
    bool hasControllerError() const;

    float getTempC() const { return m_temp; }
    float getTempF() const { return (m_temp * 9.f/5.f + 32.f); }

    void deviceConnected();
    void deviceDisconnected();
    void errorReceived(QLowEnergyController::Error);
    virtual void serviceScanDone();
    virtual void addLowEnergyService(const QBluetoothUuid &uuid);
    virtual void serviceDetailsDiscovered(QLowEnergyService::ServiceState newState);

    virtual void bleWriteDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    virtual void bleReadDone(const QLowEnergyCharacteristic &c, const QByteArray &value);
    virtual void bleReadNotify(const QLowEnergyCharacteristic &c, const QByteArray &value);

    void refreshDatasStarted();
    void refreshDatasCanceled();
    void refreshDatasFinished(bool status, bool cached = false);

    void setUpdateTimerInterval(int updateIntervalMin = 0);

    bool getSqlDatas();
    virtual bool getSqlCachedDatas(int minutes);
    bool getBleDatas();

public:
    Device(QString &deviceAddr, QString &deviceName);
    Device(const QBluetoothDeviceInfo &d);
    virtual ~Device();

public slots:
    bool refreshDatas();
    bool refreshDatasCached(int minutes = 1);
    void disconnectDevice();

    // BLE device
    QString getName() const { return m_deviceName; }
    QString getAddress() const { return m_deviceAddress; }

    bool hasHygrometrySensor() const { return (m_capabilities & DEVICE_HYGROMETRY); }
    bool hasSoilMoistureSensor() const { return (m_capabilities & DEVICE_SOIL_MOISTURE); }
    bool hasTemperatureSensor() const { return (m_capabilities & DEVICE_TEMPERATURE); }
    bool hasLuminositySensor() const { return (m_capabilities & DEVICE_LUMINOSITY); }
    bool hasConductivitySensor() const { return (m_capabilities & DEVICE_SOIL_CONDUCTIVITY); }
    bool hasBatteryLevel() const { return (m_capabilities & DEVICE_BATTERY); }

    bool isAvailable() const { return m_available; }    //!< Has at least >12h old datas
    bool isUpdating() const { return m_updating; }      //!< Is currently being updated

    // BLE device infos
    QString getFirmware() const { return m_firmware; }
    bool isFirmwareUpToDate() const { return m_firmware_uptodate; }
    int getBattery() const { return m_battery; }

    // BLE device datas
    int getHygro() const { return m_hygro; }
    int getLuminosity() const { return m_luminosity; }
    int getConductivity() const { return m_conductivity; }
    float getTemp() const;
    QString getTempString() const;
    QString getLastUpdateString() const;
    int getLastUpdateInt() const;

    bool hasDatas() const;
    bool hasDatas(const QString &dataName) const;
    int countDatas(const QString &dataName, int days = 31) const;

    // BLE device associated datas
    QString getLocationName() { return m_locationName; }
    void setLocationName(const QString &name);

    QString getPlantName() { return m_plantName; }
    void setPlantName(const QString &name);

    // BLE device limits
    int getLimitHygroMin() const { return m_limitHygroMin; }
    int getLimitHygroMax() const { return m_limitHygroMax; }
    int getLimitTempMin() const { return m_limitTempMin; }
    int getLimitTempMax() const { return m_limitTempMax; }
    int getLimitLumiMin() const { return m_limitLumiMin; }
    int getLimitLumiMax() const { return m_limitLumiMax; }
    int getLimitConduMin() const { return m_limitConduMin; }
    int getLimitConduMax() const { return m_limitConduMax; }
    void setLimitHygroMin(int limitHygroMin) { if (m_limitHygroMin == limitHygroMin) return; m_limitHygroMin = limitHygroMin; setDbLimits(); }
    void setLimitHygroMax(int limitHygroMax) { if (m_limitHygroMax == limitHygroMax) return; m_limitHygroMax = limitHygroMax; setDbLimits(); }
    void setLimitTempMin(int limitTempMin) { if (m_limitTempMin == limitTempMin) return; m_limitTempMin = limitTempMin; setDbLimits(); }
    void setLimitTempMax(int limitTempMax) { if (m_limitTempMax == limitTempMax) return; m_limitTempMax = limitTempMax; setDbLimits(); }
    void setLimitLumiMin(int limitLumiMin) { if (m_limitLumiMin == limitLumiMin) return; m_limitLumiMin = limitLumiMin; setDbLimits(); }
    void setLimitLumiMax(int limitLumiMax) { if (m_limitLumiMax == limitLumiMax) return; m_limitLumiMax = limitLumiMax; setDbLimits(); }
    void setLimitConduMin(int limitConduMin) { if (m_limitConduMin == limitConduMin) return; m_limitConduMin = limitConduMin; setDbLimits(); }
    void setLimitConduMax(int limitConduMax) { if (m_limitConduMax == limitConduMax) return; m_limitConduMax = limitConduMax; setDbLimits(); }
    bool setDbLimits();

    // AIO graph
    Q_INVOKABLE void getAioDatas(QtCharts::QDateTimeAxis *axis,
                                 QtCharts::QLineSeries *hygro, QtCharts::QLineSeries *temp,
                                 QtCharts::QLineSeries *lumi, QtCharts::QLineSeries *cond);

    // Monthly graph
    QVariantList getMonth();
    QVariantList getMonthDatas(const QString &dataName);
    QVariantList getMonthBackground(float maxValue);

    // Daily graph
    QVariantList getDays();
    QVariantList getDatasDaily(const QString &dataName);
    QVariantList getBackgroundDaily(float maxValue);

    // Hourly graph
    QVariantList getHours();
    QVariantList getDatasHourly(const QString &dataName);
    QVariantList getBackgroundHourly(float maxValue);
    QVariantList getBackgroundNightly(float maxValue);
};

/* ************************************************************************** */
#endif // DEVICE_H
