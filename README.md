# 🚀 Stress Test VM - Monitoraggio con SAR

Progetto completo per stress test di sistema VM con raccolta di **25+ metriche low-level** usando `sar`.

## 📋 **Requisiti**

### **Installazione Tool (Ubuntu/Debian):**
```bash
# Aggiorna sistema
sudo apt update

# Installa sysstat (per sar)
sudo apt install -y sysstat

# Installa benchmark
sudo apt install -y stress-ng fio nbody

# Verifica installazioni
sar --version
stress-ng --version
fio --version
nbody --help
```

## 🎯 **Cosa Fa il Progetto**

- **6 fasi da 10 minuti** = 60 minuti totali
- **Sempre ≥2 processi attivi** (CPU, MEM, I/O)
- **25+ metriche** ogni 2 secondi (1800 campioni)
- **Benchmark specifici**:
  - CPU: `nbody` (simulazione astrofisica)
  - MEM: `stress-ng --vm` (allocazione memoria)
  - I/O: `fio` (benchmark disco professionale)

## 📊 **Metriche Raccoglibili**

| Categoria | Metriche |
|-----------|----------|
| **CPU** | %user, %system, %iowait, %idle, %nice, %steal |
| **Memoria** | kbmemfree, kbmemused, %memused, kbbuffers, kbcached |
| **Swap** | kbswpfree, kbswpused, %swpused |
| **I/O** | tps, rtps, wtps, bread/s, bwrtn/s |
| **Disco** | rd_sec/s, wr_sec/s, avgrq-sz, avgqu-sz, await |
| **Rete** | rxpck/s, txpck/s, rxkB/s, txkB/s |
| **Sistema** | proc/s, cswch/s, intr/s |

## 🚀 **Come Usare**

### **1. Rendere Eseguibile lo Script:**
```bash
chmod +x stress_test_sar.sh
```

### **2. Eseguire lo Stress Test:**
```bash
./stress_test_sar.sh
```

### **3. Analizzare i Risultati:**
```bash
# Con Python
python analyze_sar.py sar_detailed_20241230_120000.csv

# O con comandi sar diretti
sar -f sar_data_20241230_120000.sa          # Report completo
sar -u -f sar_data_20241230_120000.sa       # CPU
sar -r -f sar_data_20241230_120000.sa       # Memoria
sar -b -f sar_data_20241230_120000.sa       # I/O
```

## 📈 **Fasi dello Stress Test**

| Fase | Durata | Processi Attivi | Descrizione |
|------|--------|-----------------|-------------|
| 1 | 0-10 min | CPU + MEM | nbody x2 + stress-ng --vm x3 |
| 2 | 10-20 min | CPU + I/O | nbody x2 + fio randread |
| 3 | 20-30 min | MEM + I/O | stress-ng --vm x4 + fio mixed |
| 4 | 30-40 min | CPU + MEM | nbody x3 + stress-ng --vm x2 (variante) |
| 5 | 40-50 min | CPU + MEM + I/O | Tutti e tre (livelli ridotti) |
| 6 | 50-60 min | CPU + I/O | nbody x3 + fio heavy mixed |

## 📁 **File Generati**

- `stress_test_sar_YYYYMMDD_HHMMSS.txt` - Log esecuzione
- `sar_data_YYYYMMDD_HHMMSS.sa` - Dati binari SAR
- `sar_detailed_YYYYMMDD_HHMMSS.csv` - Dati CSV per analisi
- `sar_detailed_YYYYMMDD_HHMMSS_analysis.png` - Grafici analisi

## ⚠️ **Considerazioni di Sicurezza**

- **Monitora temperatura** CPU/disco durante il test
- **Backup importanti** prima dell'esecuzione
- **Interrompi** se il sistema diventa unresponsive
- **I/O livelli conservativi** per evitare danni hardware

## 🔧 **Personalizzazione**

### **Modificare Durata Fasi:**
```bash
# Nel file stress_test_sar.sh, cambia i timeout:
stress-ng --vm 3 --vm-bytes 1.5G --timeout 300  # 5 minuti invece di 10
```

### **Modificare Intensità Stress:**
```bash
# CPU: cambia numero corpi o istanze
nbody -t 600 -b 800  # Più corpi = più stress

# MEM: cambia numero worker o dimensione
stress-ng --vm 2 --vm-bytes 3G  # Più memoria

# I/O: cambia numero job o dimensione
fio --name=test --rw=randread --size=200M --numjobs=4
```

## 📊 **Analisi Risultati**

Lo script `analyze_sar.py` genera automaticamente:
- **Grafici CPU** nel tempo
- **Grafici memoria** nel tempo
- **Grafici I/O** nel tempo
- **Grafici rete** (se disponibili)
- **Statistiche riassuntive** per ogni fase

## 🎯 **Obiettivo Raggiunto**

✅ **25+ metriche low-level** raccolte ogni 2 secondi
✅ **60 minuti** di monitoraggio continuo
✅ **6 fasi distinte** per analisi comparativa
✅ **Sempre ≥2 processi attivi** per stress realistico
✅ **Benchmark specifici** per ogni tipo di carico

Il progetto è pronto per raccogliere dati completi sulle performance della tua VM sotto stress controllato! 🚀