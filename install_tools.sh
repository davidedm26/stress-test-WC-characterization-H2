#!/bin/bash
# install_tools.sh - Script per installare tutti gli strumenti necessari

echo "=== INSTALLAZIONE STRUMENTI STRESS TEST ==="
echo "Questo script installa: sar (sysstat), stress-ng, fio, nbody"
echo ""

# Verifica se siamo su Ubuntu/Debian
if ! command -v apt >/dev/null 2>&1; then
    echo "❌ Questo script è per Ubuntu/Debian. Per altri sistemi:"
    echo "   - macOS: brew install stress-ng fio"
    echo "   - CentOS/RHEL: yum install sysstat stress-ng fio"
    exit 1
fi

# Aggiorna lista pacchetti
echo "📦 Aggiornamento lista pacchetti..."
sudo apt update

# Installa sysstat (per sar)
echo "📊 Installazione sysstat (sar)..."
sudo apt install -y sysstat

# Abilita raccolta dati sysstat
echo "⚙️  Configurazione sysstat per raccolta automatica..."
sudo systemctl enable sysstat 2>/dev/null || echo "systemctl non disponibile, configurazione manuale"
sudo systemctl start sysstat 2>/dev/null || echo "systemctl non disponibile"

# Installa stress-ng
echo "🧠 Installazione stress-ng (stress memoria)..."
sudo apt install -y stress-ng

# Installa fio
echo "💾 Installazione fio (benchmark I/O)..."
sudo apt install -y fio

# Installa nbody (se disponibile)
echo "🌌 Installazione nbody (benchmark CPU)..."
if apt-cache show nbody >/dev/null 2>&1; then
    sudo apt install -y nbody
else
    echo "⚠️  nbody non disponibile nei repo ufficiali"
    echo "   Installazione alternativa o usa stress-ng --cpu"
fi

echo ""
echo "=== VERIFICA INSTALLAZIONI ==="

# Verifica sar
if command -v sar >/dev/null 2>&1; then
    echo "✅ sar: $(sar --version 2>&1 | head -1)"
else
    echo "❌ sar: NON INSTALLATO"
fi

# Verifica stress-ng
if command -v stress-ng >/dev/null 2>&1; then
    echo "✅ stress-ng: $(stress-ng --version 2>&1 | head -1)"
else
    echo "❌ stress-ng: NON INSTALLATO"
fi

# Verifica fio
if command -v fio >/dev/null 2>&1; then
    echo "✅ fio: $(fio --version 2>&1 | head -1)"
else
    echo "❌ fio: NON INSTALLATO"
fi

# Verifica nbody
if command -v nbody >/dev/null 2>&1; then
    echo "✅ nbody: Disponibile"
else
    echo "⚠️  nbody: NON DISPONIBILE (usa stress-ng --cpu come alternativa)"
fi

echo ""
echo "=== ISTRUZIONI SUCCESSIVE ==="
echo "1. Rendere eseguibile lo script di stress test:"
echo "   chmod +x stress_test_sar.sh"
echo ""
echo "2. Eseguire lo stress test:"
echo "   ./stress_test_sar.sh"
echo ""
echo "3. Analizzare i risultati:"
echo "   python analyze_sar.py sar_detailed_*.csv"
echo ""
echo "=== CONFIGURAZIONE COMPLETATA ==="