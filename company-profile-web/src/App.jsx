import React from 'react'
import './index.css'

function App() {
  return (
    <div className="app-container">
      <div className="bg-gradient-1"></div>
      <div className="bg-gradient-2"></div>

      <nav className="navbar">
        <div className="brand">AntiRibet.</div>
        <div className="nav-links">
          <a href="#features">Fitur</a>
          <a href="#pricing">Harga</a>
          <a href="#about">Tentang Kami</a>
        </div>
        <button className="btn-primary">Mulai Sekarang</button>
      </nav>

      <main className="hero">
        <h1>Operasional Bisnis <br/>Tanpa Ribet.</h1>
        <p>
          Platform all-in-one untuk POS, Menu QR, Antrean, dan Booking. 
          Semuanya terintegrasi. Tanpa biaya langganan bulanan.
        </p>
        <div className="cta-group">
          <button className="btn-primary">Daftar Merchant Gratis</button>
          <button className="btn-secondary">Lihat Demo</button>
        </div>
      </main>

      <section id="features" className="features">
        <div className="feature-card">
          <div className="feature-icon">🚀</div>
          <h3>Kasir POS Super Cepat</h3>
          <p>Sistem Point of Sale yang responsif. Offline-first, sinkronisasi otomatis saat online.</p>
        </div>
        <div className="feature-card">
          <div className="feature-icon">📱</div>
          <h3>QR Order Mandiri</h3>
          <p>Pelanggan pesan & bayar langsung dari meja mereka menggunakan QR code. Pesanan masuk otomatis ke dapur.</p>
        </div>
        <div className="feature-card">
          <div className="feature-icon">📅</div>
          <h3>Sistem Booking & Antrean</h3>
          <p>Atur reservasi meja dan pantau antrean secara real-time dari satu dashboard.</p>
        </div>
        <div className="feature-card">
          <div className="feature-icon">💸</div>
          <h3>Pay-per-use</h3>
          <p>Tidak ada biaya bulanan wajib. Cukup bayar Rp500 untuk setiap transaksi yang berhasil.</p>
        </div>
      </section>
    </div>
  )
}

export default App
