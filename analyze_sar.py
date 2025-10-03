#!/usr/bin/env python3
"""
Analisi dati SAR dallo stress test
Utilizzo: python analyze_sar.py <sar_csv_file>
"""

import pandas as pd
import matplotlib.pyplot as plt
import sys
import os

def analyze_sar_data(csv_file):
    """Analizza i dati SAR dal file CSV"""

    print(f"Analisi dati SAR: {csv_file}")

    # Leggi file CSV
    try:
        df = pd.read_csv(csv_file, sep='\s+', skiprows=1, na_values=['-'])
    except Exception as e:
        print(f"Errore lettura file: {e}")
        return

    # Rimuovi righe di riepilogo
    df = df[df['%user'] != 'Average']

    # Converti colonne numeriche
    numeric_cols = ['%user', '%system', '%iowait', '%idle', 'kbmemfree', 'kbmemused',
                   '%memused', 'tps', 'rtps', 'wtps', 'bread/s', 'bwrtn/s']
    for col in numeric_cols:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors='coerce')

    # Aggiungi colonna tempo (ogni 2 secondi)
    df['time_seconds'] = range(0, len(df) * 2, 2)

    print(f"Campioni caricati: {len(df)}")
    print(f"Durata: {len(df) * 2} secondi ({len(df) * 2 // 60} minuti)")
    print(f"Colonne disponibili: {len(df.columns)}")
    print("\nPrime 10 colonne:")
    for i, col in enumerate(df.columns[:10], 1):
        print(f"{i:2d}. {col}")

    # Plot fasi
    phases = [
        (0, 600, 'CPU (matrix) + MEM'),
        (600, 1200, 'CPU (fft) + I/O'),
        (1200, 1800, 'MEM + I/O'),
        (1800, 2400, 'CPU (ackermann) + MEM'),
        (2400, 3000, 'CPU (fibonacci) + MEM + I/O'),
        (3000, 3600, 'CPU (callfunc) + I/O')
    ]

    plt.figure(figsize=(15, 10))

    # Plot CPU
    plt.subplot(2, 2, 1)
    if '%user' in df.columns:
        plt.plot(df['time_seconds'], df['%user'], label='User %')
    if '%system' in df.columns:
        plt.plot(df['time_seconds'], df['%system'], label='System %')
    if '%iowait' in df.columns:
        plt.plot(df['time_seconds'], df['%iowait'], label='I/O Wait %')
    plt.title('CPU Usage Over Time')
    plt.xlabel('Time (seconds)')
    plt.ylabel('CPU %')
    plt.legend()
    plt.grid(True, alpha=0.3)

    # Aggiungi linee fasi
    for start, end, label in phases:
        plt.axvspan(start, end, alpha=0.1, label=label)

    # Plot Memoria
    plt.subplot(2, 2, 2)
    if 'kbmemused' in df.columns:
        plt.plot(df['time_seconds'], df['kbmemused']/1024/1024, label='Used (GB)')
    if 'kbcached' in df.columns:
        plt.plot(df['time_seconds'], df['kbcached']/1024/1024, label='Cached (GB)')
    plt.title('Memory Usage Over Time')
    plt.xlabel('Time (seconds)')
    plt.ylabel('Memory (GB)')
    plt.legend()
    plt.grid(True, alpha=0.3)

    # Plot I/O
    plt.subplot(2, 2, 3)
    if 'rtps' in df.columns:
        plt.plot(df['time_seconds'], df['rtps'], label='Read TPS')
    if 'wtps' in df.columns:
        plt.plot(df['time_seconds'], df['wtps'], label='Write TPS')
    plt.title('I/O Operations Over Time')
    plt.xlabel('Time (seconds)')
    plt.ylabel('TPS')
    plt.legend()
    plt.grid(True, alpha=0.3)

    # Plot Network (se disponibile)
    plt.subplot(2, 2, 4)
    network_plotted = False
    if 'rxkB/s' in df.columns:
        plt.plot(df['time_seconds'], df['rxkB/s'], label='RX kB/s')
        network_plotted = True
    if 'txkB/s' in df.columns:
        plt.plot(df['time_seconds'], df['txkB/s'], label='TX kB/s')
        network_plotted = True

    if network_plotted:
        plt.title('Network Traffic Over Time')
        plt.xlabel('Time (seconds)')
        plt.ylabel('kB/s')
        plt.legend()
        plt.grid(True, alpha=0.3)
    else:
        plt.text(0.5, 0.5, 'Network data\nnot available', ha='center', va='center', transform=plt.gca().transAxes)
        plt.title('Network Traffic (N/A)')

    plt.tight_layout()

    # Salva plot
    output_file = csv_file.replace('.csv', '_analysis.png')
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"\nGrafico salvato: {output_file}")

    # Statistiche riassuntive per fase
    print("\n=== STATISTICHE PER FASE ===")
    for start, end, label in phases:
        phase_data = df[(df['time_seconds'] >= start) & (df['time_seconds'] < end)]
        if len(phase_data) > 0:
            print(f"\n{label} ({start//60}-{end//60} min, {len(phase_data)} campioni):")
            if '%user' in phase_data.columns:
                print(".1f")
            if '%iowait' in phase_data.columns:
                print(".1f")
            if 'kbmemused' in phase_data.columns:
                print(".1f")
            if 'rtps' in phase_data.columns:
                print(".1f")

    plt.show()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Utilizzo: python analyze_sar.py <sar_csv_file>")
        print("Esempio: python analyze_sar.py sar_detailed_20241230_120000.csv")
        sys.exit(1)

    csv_file = sys.argv[1]
    if not os.path.exists(csv_file):
        print(f"File non trovato: {csv_file}")
        sys.exit(1)

    analyze_sar_data(csv_file)