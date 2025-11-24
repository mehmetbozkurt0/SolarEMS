from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any

# main.py dosyasının başındaki import satırını değiştir:
from ml_core import (
    get_production_prediction, 
    get_ai_optimization_recommendation, 
    get_detailed_forecast,
    get_financial_summary, # YENİ
    get_environmental_data # YENİ
)

# YENİ EKLEME: ML Core Modülünü İçe Aktar
from ml_core import get_production_prediction, get_ai_optimization_recommendation, get_detailed_forecast 


# ==================== 1. MODELLER (FastAPI Pydantic) ====================
# API'nin ve Flutter'ın kullanacağı veri yapıları.

class ChartDataPointResponse(BaseModel):
    """Grafik çubuğu verisi."""
    label: str
    height: float
    is_high: bool

class AIRecommendationResponse(BaseModel):
    """AI Optimizasyon Önerisi Kartı."""
    title: str
    message: str
    estimated_gain: float 

class ForecastDetail(BaseModel):
    """Detaylı 24s Üretim Tahmin Pop-up verisi (YENİ)"""
    time: str
    value: str
    efficiency: str
    iconName: str
    
class DeviceModel(BaseModel):
    """Cihaz Yönetimi için temel cihaz yapısı."""
    id: str
    name: str
    type: str  
    status: str
    power: str

class BatterySettingsModel(BaseModel):
    """Batarya ayarlarını güncellemek için gelen veri."""
    isActive: bool
    voltageLimit: float
    maxChargeLimit: float
    notifyLowBattery: bool

class BatteryModel(BaseModel):
    """Batarya Analiz ekranı için detaylı batarya verisi."""
    id: str
    name: str
    chargeLevel: float 
    isActive: bool
    voltageLimit: float
    maxChargeLimit: float
    notifyLowBattery: bool
    status: str
    temp: str

# main.py dosyasında, MODELLER kısmına ekle:

class FinancialSummary(BaseModel):
    toplam_eski: float
    toplam_yeni: float
    kazanc: float
    tasarruf_yuzdesi: float

class EnvironmentalImpact(BaseModel):
    toplam_uretim_kwh: float
    onlenen_co2_kg: float
    kurtarilan_agac: float

# ==================== 2. UYGULAMA VE ORTAM AYARLARI (APP TANIMLAMA) ====================
# FastAPi uygulaması burada tanımlanır. Tüm @app.get/@app.post'lar bu satırdan sonra gelmeli!

app = FastAPI(
    title="Solar EMS ML Backend API",
    description="Enerji Yönetimi Sistemi için ML tahmin ve veri servisleri.",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==================== 3. MOCK VERİ TABANI (DB yerine geçici liste) ====================

MOCK_BATTERIES: List[Dict[str, Any]] = [
    {
      'id': 'bat-001', 'name': 'Ana Depolama (Tesla Powerwall)', 'chargeLevel': 0.78, 
      'isActive': True, 'voltageLimit': 48.0, 'maxChargeLimit': 90.0, 
      'notifyLowBattery': True, 'status': 'Discharging (-1.2 kW)', 'temp': '24°C',
    },
    {
      'id': 'bat-002', 'name': 'Yedek Ünite 1 (LG Chem)', 'chargeLevel': 0.45, 
      'isActive': True, 'voltageLimit': 48.0, 'maxChargeLimit': 100.0, 
      'notifyLowBattery': True, 'status': 'Standby', 'temp': '21°C',
    },
]
MOCK_DEVICES: List[Dict[str, Any]] = [
    {"id": "inv-001", "name": "Ana İnverter", "type": "Inverter", "status": "Online", "power": "4.2 kW"},
    {"id": "bat-001", "name": "Tesla Powerwall", "type": "Batarya", "status": "Charging", "power": "+2.1 kW"},
    {"id": "meter-01", "name": "Akıllı Sayaç", "type": "Sayaç", "status": "Online", "power": "--"},
    {"id": "ac-001", "name": "Salon Kliması", "type": "Tüketici", "status": "Offline", "power": "0 kW"},
]


# ==================== 4. API ENDPOINTS (v1) ====================

@app.get("/api/v1/health")
async def check_health():
    """API'nin ayakta olduğunu doğrular."""
    return {"status": "ok", "message": "ML/Data API is running."}

# --- ML ve TAHMİN ENDPOINTS'leri ---

@app.get("/api/v1/ai/recommendation", response_model=AIRecommendationResponse)
async def get_ai_recommendation():
    """Anlık optimizasyon önerisini sunar."""
    return get_ai_optimization_recommendation()

@app.post("/api/v1/ai/recommendation/apply")
async def apply_ai_recommendation():
    """AI önerisi uygulama endpoint'i."""
    return {"message": "AI optimizasyon önerisi sisteme başarıyla uygulandı."}


# --- GRAFİK VE ANALİZ ENDPOINTS'leri ---

@app.get("/api/v1/analysis/chart/production/daily", response_model=List[ChartDataPointResponse])
async def get_daily_production_chart():
    """24 saatlik üretim grafiği verisini sağlar (Dashboard Grafik)."""
    return get_production_prediction(hours=24)

@app.get("/api/v1/analysis/forecast/detailed", response_model=List[ForecastDetail])
async def get_detailed_forecast_api():
    """Detaylı 24s tahmin verisini sağlar (Pop-up Liste)."""
    return get_detailed_forecast(hours=24)


# --- CİHAZ YÖNETİMİ ENDPOINTS'leri ---

@app.get("/api/v1/devices", response_model=List[DeviceModel])
async def list_devices():
    """Tüm kayıtlı cihazları listeler."""
    return MOCK_DEVICES

@app.post("/api/v1/devices", response_model=DeviceModel)
async def add_device(device: DeviceModel):
    """Yeni bir cihaz ekler."""
    MOCK_DEVICES.append(device.model_dump())
    return device

@app.delete("/api/v1/devices/{device_id}")
async def delete_device(device_id: str):
    """Belirtilen cihazı siler."""
    global MOCK_DEVICES
    initial_count = len(MOCK_DEVICES)
    MOCK_DEVICES = [d for d in MOCK_DEVICES if d['id'] != device_id]
    if len(MOCK_DEVICES) == initial_count:
        raise HTTPException(status_code=404, detail="Cihaz bulunamadı.")
    return {"message": f"Cihaz {device_id} başarıyla silindi."}


# --- BATARYA YÖNETİMİ ENDPOINTS'leri ---

@app.get("/api/v1/battery", response_model=List[BatteryModel])
async def get_battery_status():
    """Tüm batarya birimlerinin anlık durumunu ve ayarlarını getirir."""
    return MOCK_BATTERIES

@app.put("/api/v1/battery/{battery_id}/settings")
async def update_battery_settings(battery_id: str, settings: BatterySettingsModel):
    """Belirli bir bataryanın ayarlarını günceller."""
    found = False
    for battery in MOCK_BATTERIES:
        if battery['id'] == battery_id:
            battery.update(settings.model_dump())
            found = True
            break
    
    if not found:
        raise HTTPException(status_code=404, detail="Batarya bulunamadı.")
        
    return {"message": f"Batarya {battery_id} ayarları güncellendi."}

# --- RAPORLAMA ENDPOINTS'leri ---

@app.post("/api/v1/reports/generate")
async def trigger_report_generation(report_type: str = "daily_production"):
    """Belirtilen türde bir rapor oluşturma işlemini arka planda tetikler."""
    return {"message": f"{report_type} raporu oluşturma işlemi başlatıldı."}



# --- FİNANSAL VE ÇEVRESEL ANALİZ ENDPOINTS'leri ---

@app.get("/api/v1/analysis/financial/summary", response_model=FinancialSummary)
async def get_financial_summary_api():
    """Tarife ve fatura analiz özetini sağlar."""
    return get_financial_summary()

@app.get("/api/v1/analysis/environmental/impact", response_model=EnvironmentalImpact)
async def get_environmental_impact_api():
    """Çevresel etki özetini sağlar."""
    return get_environmental_data()