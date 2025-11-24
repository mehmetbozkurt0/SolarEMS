import joblib
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional # <-- İŞTE HATA BURADAYDI, 'Optional' eklendi!



# Kütüphanelerin kurulu olduğundan emin ol: pip install joblib pandas scikit-learn

# ======================= 1. MODEL VE VERİ YÜKLEME =======================
URETIM_MODEL_PATH = 'uretim_tahmin_modeli.joblib'
TUKETIM_MODEL_PATH = 'tuketim_tahmin_modeli.joblib' 

# Global değişkenler
URETIM_MODEL = None
TUKETIM_MODEL = None
BACKEND_DATA = None # Tüm backend modüllerinin kullanacağı veri

try:
    URETIM_MODEL = joblib.load(URETIM_MODEL_PATH)
    TUKETIM_MODEL = joblib.load(TUKETIM_MODEL_PATH)
    print("✅ ML Modelleri Başarıyla Yüklendi.")
except Exception as e:
    print(f"⚠️ MODEL YÜKLEME HATASI: Modeller yüklenemedi. Hata: {e}")

def _load_data_for_backend():
    """
    Backend Modülleri için gereken (geçmiş) verileri yükler. 
    Bu veriler Anomali Tespiti ve Çevresel Etki Modülleri için kullanılır.
    """
    global BACKEND_DATA
    try:
        # Notebook'larda oluşturulan temiz dosyaları yüklüyoruz.
        df_solar = pd.read_csv('temiz_solar_veri.csv', index_col='time', parse_dates=True).resample('h').mean()
        df_tuketim = pd.read_csv('temiz_tuketim_veri_5000kWh.csv', index_col='dt', parse_dates=True).resample('h').mean()
        
        # Timezone temizliği
        df_solar.index = df_solar.index.tz_localize(None)
        df_tuketim.index = df_tuketim.index.tz_localize(None)
        
        # Verileri birleştirme
        df_final = pd.concat([df_tuketim, df_solar[['Uretim_W', 'Sicaklik_C']]], axis=1, join='inner').dropna()
        
        # Tahmin sütununu (Anomali Tespiti için gerekli) ekleyelim.
        # Basitleştirme: Modelin beklediği 4 özelliği hazırlayıp tahmin yapalım.
        features = ['Sicaklik_C', 'Global_Isinim', 'Ruzgar_Hizi', 'Gunes_Yuksekligi']
        
        # Bu kısım sadece df_final'ın son 500 saatlik bölümünü kullanır (Hafıza verimli olsun diye)
        df_anomali = df_final.tail(500).copy()
        
        if URETIM_MODEL is not None:
             # Tahmin için gerekli 4 mock özelliği ekleyelim (Bu sadece simülasyon, normalde bu verilere ihtiyacınız olmaz):
             df_anomali['Global_Isinim'] = df_anomali['Uretim_W'] * 10
             df_anomali['Gunes_Yuksekligi'] = df_anomali.index.hour.map(lambda h: max(0.0, 90 - abs(12 - h) * 10))
             df_anomali['Ruzgar_Hizi'] = df_anomali['Uretim_W'] / 1000
             
             # Tahmin yapılması
             df_anomali['Tahmin_Uretim_W'] = URETIM_MODEL.predict(df_anomali[features])
        else:
             df_anomali['Tahmin_Uretim_W'] = df_anomali['Uretim_W'] * 1.05 # Model yoksa %5 fazla tahmin etsin

        BACKEND_DATA = df_anomali
        print("✅ Backend Verisi Başarıyla Yüklendi.")
        return True
    except Exception as e:
        print(f"❌ Veri Yükleme Hatası (CSV): {e}")
        return False

# API başlatılırken veriyi yükleyelim
_load_data_for_backend()

# ======================= 2. YARDIMCI MODÜLLER (backend_modulleri.ipynb'den) =======================

def _check_for_anomalies() -> Optional[Dict[str, Any]]:
    """
    Üretim verisindeki anormallikleri (arıza/gölgeleme) kontrol eder.
    """
    if BACKEND_DATA is None: return None
    
    # Anomali Mantığı: Gerçek Üretim, Tahminin %60'ından az ve üretim 100W'tan fazlaysa
    df = BACKEND_DATA
    df['Performans_Orani'] = df['Uretim_W'] / df['Tahmin_Uretim_W']
    
    # Gündüz anomalilerini bul
    anomaliler = df[(df['Performans_Orani'] < 0.60) & (df['Tahmin_Uretim_W'] > 50) & (df.index.hour.isin(range(8, 18)))]

    if not anomaliler.empty:
        son_anomali = anomaliler.iloc[-1]
        tarih = son_anomali.name.strftime('%Y-%m-%d %H:%M')
        
        return {
            "type": "ANOMALY",
            "title": "Kritik Verim Düşüşü Tespit Edildi!",
            "message": f"Son kontrol ({tarih}): Beklenen üretim {son_anomali['Tahmin_Uretim_W']:.0f} W iken, gerçekleşen {son_anomali['Uretim_W']:.0f} W. Lütfen panel yüzeyini kontrol edin. ",
            "estimated_gain": 0.0,
        }
    return None

def _calculate_environmental_impact() -> str:
    """Toplam çevresel etkiyi hesaplar ve bir özet mesajı döndürür."""
    if BACKEND_DATA is None: return ""
    
    CO2_KATSAYISI = 0.44 # kg/kWh
    
    toplam_uretim_kwh = BACKEND_DATA['Uretim_W'].sum() / 1000
    onlenen_co2_kg = toplam_uretim_kwh * CO2_KATSAYISI
    kurtarilan_agac = onlenen_co2_kg / 20 # 1 ağaç 20 kg CO2 emer
    
    return f"Toplam {toplam_uretim_kwh:.0f} kWh temiz enerji ürettiniz. Bu, yaklaşık {kurtarilan_agac:.0f} adet ağacın faydasına eşittir."

# ======================= 3. TAHMİN VE ÖNERİ FONKSİYONLARI =======================

# ... (prepare_data_for_prediction ve get_production_prediction fonksiyonları aynı kalacak) ...
# ... (uzun olmaması için bu iki fonksiyonun içeriği aynı varsayılmıştır) ...

# TAHMİN FONKSİYONLARI BURADA BAŞLIYOR

def prepare_data_for_prediction(data_type: str, hours: int = 24) -> pd.DataFrame:
    # Uretim ve Tuketim notebook'larında kullandığınız son versiyonu kullanın
    # (Özellik adı uyuşmazlığı hatasını çözen versiyon)
    current_time = datetime.now().replace(minute=0, second=0, microsecond=0)
    future_dates = [current_time + timedelta(hours=i) for i in range(hours)]
    df = pd.DataFrame(index=future_dates)
    
    if data_type == 'production':
        df['Gunes_Yuksekligi'] = [max(0.0, 90 - abs(12 - (current_time + timedelta(hours=i)).hour) * 10) for i in range(hours)]
        df['Sicaklik_C'] = [20 + 5 * np.cos(np.pi * ((current_time + timedelta(hours=i)).hour - 12) / 12) for i in range(hours)]
        df['Ruzgar_Hizi'] = [1.0 + 4.0 * ((i % 10) / 10) for i in range(hours)]
        df['Global_Isinim'] = [g * 5.0 for g in df['Gunes_Yuksekligi']] 
        return df[['Sicaklik_C', 'Global_Isinim', 'Ruzgar_Hizi', 'Gunes_Yuksekligi']]

    elif data_type == 'consumption':
        df['Saat'] = df.index.hour
        df['Ay'] = df.index.month
        df['Haftanin_Gunu'] = df.index.dayofweek
        df['Hafta_Sonu'] = (df.index.dayofweek >= 5).astype(int)
        df['Sicaklik_C'] = [20 + 5 * np.cos(np.pi * ((current_time + timedelta(hours=i)).hour - 12) / 12) for i in range(hours)]
        
        # Geçmiş tüketim değerleri (Mock - Gerçekte son saatten alınmalı)
        df['Tuketim_1Saat_Once'] = 1200  
        df['Tuketim_24Saat_Once'] = 1800 
        df['Hareketli_Ort_3Saat'] = 1500 
        
        features = ['Saat', 'Ay', 'Haftanin_Gunu', 'Hafta_Sonu', 'Sicaklik_C', 
                    'Tuketim_1Saat_Once', 'Tuketim_24Saat_Once', 'Hareketli_Ort_3Saat']
        return df[features]
    
    return pd.DataFrame() 

def get_production_prediction(hours: int = 24) -> List[Dict[str, Any]]:
    # ... (ML ile tahmini yapıp grafik verisini döndüren fonksiyonun içeriği aynı kalacak) ...
    if URETIM_MODEL is None:
        return []
    X_future = prepare_data_for_prediction('production', hours)
    production_predictions = URETIM_MODEL.predict(X_future)
    results = []
    for timestamp, prediction in zip(X_future.index, production_predictions):
        prediction_kw = max(0, prediction) / 1000.0
        height_scale = min(1.0, prediction_kw / 5.0) 
        is_high = prediction_kw > 2.0 
        results.append({
            "label": timestamp.strftime("%H:%M"),
            "height": height_scale,
            "is_high": is_high,
        })
    return results

def get_detailed_forecast(hours: int = 24) -> List[Dict[str, Any]]:
    # ... (Pop-up için detaylı tahmin verisini döndüren fonksiyonun içeriği aynı kalacak) ...
    if URETIM_MODEL is None: return []
    X_future = prepare_data_for_prediction('production', hours)
    production_predictions = URETIM_MODEL.predict(X_future)
    results = []
    for timestamp, prediction in zip(X_future.index, production_predictions):
        prediction_w = max(0, prediction) # Watt
        prediction_kw = prediction_w / 1000.0 # KW
        max_capacity_w = 6000 
        efficiency_percent = int(min(1.0, prediction_w / max_capacity_w) * 100)
        current_hour = timestamp.hour
        icon_name = "nights_stay"
        if prediction_kw > 3.0: icon_name = "wb_sunny" 
        elif prediction_kw > 0.5 and current_hour > 7 and current_hour < 19: icon_name = "wb_cloudy"
        results.append({
            "time": timestamp.strftime("%H:%M"),
            "value": f"{prediction_kw:.1f} kW",
            "efficiency": f"{efficiency_percent}%",
            "iconName": icon_name, 
        })
    return results

def get_ai_optimization_recommendation() -> Dict[str, Any]:
    """
    ANA AI ASİSTAN FONKSİYONU: 
    1. Önce Anomali (Arıza) Kontrolü Yapılır (Kritik uyarı önceliklidir).
    2. Sonra Finansal Optimizasyon Kontrolü Yapılır.
    """
    if TUKETIM_MODEL is None or URETIM_MODEL is None:
        return {
            "title": "Model Yüklenemedi",
            "message": "Tahmin modelleri bulunamadığı için optimizasyon önerisi sunulamıyor.",
            "estimated_gain": 0.0,
        }
        
    # --- 1. KRİTİK ANOMALİ KONTROLÜ (backend_modulleri.ipynb) ---
    anomali_result = _check_for_anomalies()
    if anomali_result:
        # Anomali varsa, hemen bu uyarıyı döndür (En Yüksek Öncelik)
        return anomali_result
        
    # --- 2. FİNANSAL OPTİMİZASYON (Gelecek Tahmini) ---
    hours_to_predict = 4 
    X_tuketim = prepare_data_for_prediction('consumption', hours_to_predict)
    X_uretim = prepare_data_for_prediction('production', hours_to_predict)
    
    tuketim_tahmin = TUKETIM_MODEL.predict(X_tuketim)
    uretim_tahmin = URETIM_MODEL.predict(X_uretim)
    
    excess_energy_sum_kW = (uretim_tahmin.sum() - tuketim_tahmin.sum()) / 1000
    
    environmental_message = _calculate_environmental_impact() # Çevresel etkiyi alalım
    
    # Basitleştirilmiş Optimizasyon Mantığı:
    if excess_energy_sum_kW > 4.0: 
        return {
            "title": "Batarya Şarj Optimizasyonu Öneriliyor",
            "message": f"Önümüzdeki saatlerde üretim fazlanız ({excess_energy_sum_kW:.1f} kWh) yüksek olacak. Fazla enerjiyi bataryada depolayın. {environmental_message}",
            "estimated_gain": round(excess_energy_sum_kW * 0.40, 2), 
        }
    elif tuketim_tahmin.max() > 4000 and uretim_tahmin.max() < 1000 and datetime.now().hour in range(17, 22):
        return {
            "title": "PUANT Saat Tüketim Optimizasyonu",
            "message": f"Şu an en pahalı saat dilimindesiniz. Batarya deşarjını başlatarak şebekeden çekimi durdurun. {environmental_message}",
            "estimated_gain": 0.0,
        }
    else:
        return {
            "title": "Sistem Stabil",
            "message": f"Enerji akışınız beklenene yakın seyrediyor. {environmental_message}",
            "estimated_gain": 0.0,
        }
    
def get_financial_summary():
    """Finansal Analiz sonuçlarını döndürür (finansal_analiz.ipynb mantığı)."""
    if BACKEND_DATA is None:
        return {
            "toplam_eski": 0.0,
            "toplam_yeni": 0.0,
            "kazanc": 0.0,
            "tasarruf_yuzdesi": 0.0
        }
        
    # Finansal analiz mantığını tekrar çalıştırmak yerine, basitleştirilmiş bir hesaplama yapıyoruz
    # Gerçek uygulamada, finansal_analiz.ipynb'deki tüm adımlar burada çalışmalıdır.
    
    # Mock Fiyatlar (finansal_analiz.ipynb'den alınmıştır)
    FIYAT_GUNDUZ = 3.00  
    FIYAT_PUANT  = 5.00  
    FIYAT_GECE   = 1.50  
    
    def tarife_belirle(saat):
        if 6 <= saat < 17: return FIYAT_GUNDUZ
        elif 17 <= saat < 22: return FIYAT_PUANT
        else: return FIYAT_GECE
    
    df = BACKEND_DATA.copy()
    
    # Net Fatura Hesaplaması (kW cinsinden)
    df['Net_Tuketim_W'] = df['Tuketim_W'] - df['Uretim_W']
    df['Sebekeden_Alinan_W'] = df['Net_Tuketim_W'].clip(lower=0)
    
    # Fiyat Ekleme
    df['Birim_Fiyat_TL'] = df.index.hour.map(tarife_belirle)
    
    # Senaryo 1: Panel Yok
    df['Fatura_Eski'] = (df['Tuketim_W'] / 1000) * df['Birim_Fiyat_TL']
    toplam_eski = df['Fatura_Eski'].sum()
    
    # Senaryo 2: Panel Var
    df['Fatura_Yeni'] = (df['Sebekeden_Alinan_W'] / 1000) * df['Birim_Fiyat_TL']
    toplam_yeni = df['Fatura_Yeni'].sum()
    
    kazanc = toplam_eski - toplam_yeni
    tasarruf_yuzdesi = (kazanc / toplam_eski) * 100 if toplam_eski > 0 else 0
    
    return {
        "toplam_eski": round(toplam_eski, 2),
        "toplam_yeni": round(toplam_yeni, 2),
        "kazanc": round(kazanc, 2),
        "tasarruf_yuzdesi": round(tasarruf_yuzdesi, 1)
    }

def get_environmental_data():
    """Çevresel Etki Modülü sonuçlarını döndürür."""
    if BACKEND_DATA is None:
        return {
            "toplam_uretim_kwh": 0.0,
            "onlenen_co2_kg": 0.0,
            "kurtarilan_agac": 0.0
        }
        
    CO2_KATSAYISI = 0.44
    
    df = BACKEND_DATA
    toplam_uretim_kwh = df['Uretim_W'].sum() / 1000
    onlenen_co2_kg = toplam_uretim_kwh * CO2_KATSAYISI
    kurtarilan_agac = onlenen_co2_kg / 20

    return {
        "toplam_uretim_kwh": round(toplam_uretim_kwh, 2),
        "onlenen_co2_kg": round(onlenen_co2_kg, 2),
        "kurtarilan_agac": round(kurtarilan_agac, 1)
    }