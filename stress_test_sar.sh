#!/bin/bash
# stress_test_sar_complete.sh - Monitoraggio con sar per 25+ metriche

LOG_FILE="stress_test_sar_$(date +%Y%m%d_%H%M%S).txt"
SAR_BINARY="sar_data_$(date +%Y%m%d_%H%M%S).sa"
SAR_CSV="sar_detailed_$(date +%Y%m%d_%H%M%S).csv"

echo "=== STRESS TEST CON SAR - 25+ METRICHE ===" | tee -a "$LOG_FILE"
echo "Durata: 60 minuti | Intervallo: 2 secondi | Campioni: 1800" | tee -a "$LOG_FILE"
echo "File binario: $SAR_BINARY" | tee -a "$LOG_FILE"
echo "File CSV: $SAR_CSV" | tee -a "$LOG_FILE"
echo "Processi attivi: sempre ≥2 (CPU/MEM/I/O)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Verifica installazione strumenti
check_tools() {
    local missing=""
    command -v sar >/dev/null 2>&1 || missing="$missing sar(sysstat)"
    command -v stress-ng >/dev/null 2>&1 || missing="$missing stress-ng"
    command -v fio >/dev/null 2>&1 || missing="$missing fio"

    if [ -n "$missing" ]; then
        echo "ERROR: Strumenti mancanti:$missing" | tee -a "$LOG_FILE"
        echo "Installa con: sudo apt install$missing" | tee -a "$LOG_FILE"
        exit 1
    fi
}

check_tools

# Avvia monitoraggio sar (tutte le metriche)
echo "Avvio monitoraggio sar (tutte le metriche, intervallo 2s)..." | tee -a "$LOG_FILE"
sar -o "$SAR_BINARY" 2 1800 >/dev/null &
SAR_PID=$!

# Avvia anche output CSV per analisi immediata
sar -A 2 1800 > "$SAR_CSV" &
SAR_CSV_PID=$!

# Fase 1: CPU + MEM (10 minuti)
echo "$(date): FASE 1 - CPU + MEM (10 min)" | tee -a "$LOG_FILE"
echo "CPU: stress-ng --cpu 4 (matrix) | MEM: stress-ng --vm 3 (1.5GB)" | tee -a "$LOG_FILE"
stress-ng --cpu 4 --cpu-method matrix --timeout 600 &
stress-ng --vm 3 --vm-bytes 1.5G --timeout 600
echo "$(date): Fase 1 completata" | tee -a "$LOG_FILE"

# Fase 2: CPU + I/O (10 minuti)
echo "$(date): FASE 2 - CPU + I/O (10 min)" | tee -a "$LOG_FILE"
echo "CPU: stress-ng --cpu 4 (fft) | I/O: fio randread (2 job, 100MB)" | tee -a "$LOG_FILE"
stress-ng --cpu 4 --cpu-method fft --timeout 600 &
fio --name=randread --rw=randread --bs=4k --size=100M --numjobs=2 --runtime=600 --time_based
echo "$(date): Fase 2 completata" | tee -a "$LOG_FILE"

# Fase 3: MEM + I/O (10 minuti)
echo "$(date): FASE 3 - MEM + I/O (10 min)" | tee -a "$LOG_FILE"
echo "MEM: stress-ng --vm 4 (1GB) | I/O: fio mixed (3 job, 150MB)" | tee -a "$LOG_FILE"
stress-ng --vm 4 --vm-bytes 1G --timeout 600 &
fio --name=mixed --rw=randrw --rwmixread=70 --bs=4k --size=150M --numjobs=3 --runtime=600 --time_based
echo "$(date): Fase 3 completata" | tee -a "$LOG_FILE"

# Fase 4: CPU + MEM variante (10 minuti)
echo "$(date): FASE 4 - CPU + MEM variante (10 min)" | tee -a "$LOG_FILE"
echo "CPU: stress-ng --cpu 6 (ackermann) | MEM: stress-ng --vm 2 (2GB)" | tee -a "$LOG_FILE"
stress-ng --cpu 6 --cpu-method ackermann --timeout 600 &
stress-ng --vm 2 --vm-bytes 2G --timeout 600
echo "$(date): Fase 4 completata" | tee -a "$LOG_FILE"

# Fase 5: Tutti e tre (10 minuti)
echo "$(date): FASE 5 - Tutti e tre (10 min)" | tee -a "$LOG_FILE"
echo "CPU: stress-ng --cpu 2 (fibonacci) | MEM: stress-ng --vm 2 (800MB) | I/O: fio light (2 job, 50MB)" | tee -a "$LOG_FILE"
stress-ng --cpu 2 --cpu-method fibonacci --timeout 600 &
stress-ng --vm 2 --vm-bytes 800M --timeout 600 &
fio --name=light --rw=randread --bs=4k --size=50M --numjobs=2 --runtime=600 --time_based
echo "$(date): Fase 5 completata" | tee -a "$LOG_FILE"

# Fase 6: CPU + I/O variante pesante (10 minuti)
echo "$(date): FASE 6 - CPU + I/O variante pesante (10 min)" | tee -a "$LOG_FILE"
echo "CPU: stress-ng --cpu 6 (callfunc) | I/O: fio heavy mixed (4 job, 200MB)" | tee -a "$LOG_FILE"
stress-ng --cpu 6 --cpu-method callfunc --timeout 600 &
fio --name=heavy --rw=randrw --rwmixread=60 --bs=4k --size=200M --numjobs=4 --runtime=600 --time_based
echo "$(date): Fase 6 completata" | tee -a "$LOG_FILE"

# Cleanup processi monitoraggio
kill $SAR_PID 2>/dev/null
kill $SAR_CSV_PID 2>/dev/null
wait $SAR_PID 2>/dev/null
wait $SAR_CSV_PID 2>/dev/null

echo "" | tee -a "$LOG_FILE"
echo "=== STRESS TEST COMPLETATO ===" | tee -a "$LOG_FILE"
echo "Durata totale: 60 minuti" | tee -a "$LOG_FILE"
echo "Campioni totali: $(wc -l < "$SAR_CSV")" | tee -a "$LOG_FILE"
echo "File dati binari: $SAR_BINARY" | tee -a "$LOG_FILE"
echo "File dati CSV: $SAR_CSV" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "Comandi per analisi:" | tee -a "$LOG_FILE"
echo "  sar -f $SAR_BINARY          # Report completo" | tee -a "$LOG_FILE"
echo "  sar -u -f $SAR_BINARY       # CPU usage" | tee -a "$LOG_FILE"
echo "  sar -r -f $SAR_BINARY       # Memory usage" | tee -a "$LOG_FILE"
echo "  sar -b -f $SAR_BINARY       # I/O statistics" | tee -a "$LOG_FILE"
echo "  sar -n DEV -f $SAR_BINARY   # Network statistics" | tee -a "$LOG_FILE"