#!/bin/bash
# quick_test.sh - Test rapido degli strumenti installati

echo "=== TEST RAPIDO STRUMENTI ==="
echo ""

# Test sar
echo "📊 Test sar (5 secondi, 3 campioni):"
if command -v sar >/dev/null 2>&1; then
    sar 1 3
    echo "✅ sar: OK"
else
    echo "❌ sar: NON TROVATO"
fi

echo ""

# Test stress-ng
echo "🧠 Test stress-ng (CPU, 2 secondi):"
if command -v stress-ng >/dev/null 2>&1; then
    timeout 3 stress-ng --cpu 1 --timeout 2 >/dev/null 2>&1
    echo "✅ stress-ng: OK"
else
    echo "❌ stress-ng: NON TROVATO"
fi

echo ""

# Test fio
echo "💾 Test fio (I/O leggero, 2 secondi):"
if command -v fio >/dev/null 2>&1; then
    fio --name=quicktest --rw=randread --bs=4k --size=1M --numjobs=1 --runtime=2 --time_based >/dev/null 2>&1
    echo "✅ fio: OK"
else
    echo "❌ fio: NON TROVATO"
fi

echo ""

# Test stress-ng CPU
echo "🔥 Test stress-ng CPU (matrix, 2 secondi):"
if command -v stress-ng >/dev/null 2>&1; then
    timeout 3 stress-ng --cpu 2 --cpu-method matrix --timeout 2 >/dev/null 2>&1
    echo "✅ stress-ng CPU: OK"
else
    echo "❌ stress-ng CPU: NON TROVATO"
fi

echo ""
echo "=== TEST COMPLETATO ==="
echo "Se tutti gli strumenti sono OK, puoi eseguire:"
echo "  ./stress_test_sar.sh"