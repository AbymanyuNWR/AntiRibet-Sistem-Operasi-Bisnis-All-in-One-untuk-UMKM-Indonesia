<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Masuk - AntiRibet</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>body { font-family: 'Plus Jakarta Sans', sans-serif; background: #FAFBFC; }</style>
</head>
<body class="min-h-screen flex items-center justify-center p-4">
    <div class="bg-white p-8 rounded-2xl shadow-sm border border-gray-100 w-full max-w-md">
        <div class="text-center mb-8">
            <h1 class="text-2xl font-bold text-[#0052CC] mb-2">Masuk Kasir</h1>
            <p class="text-gray-500">Selamat datang kembali di AntiRibet.</p>
        </div>
        
        <form id="loginForm" class="space-y-4">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                <input type="email" id="email" class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#0052CC] focus:border-transparent outline-none" required>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Password</label>
                <input type="password" id="password" class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-[#0052CC] focus:border-transparent outline-none" required>
            </div>
            <button type="submit" class="w-full bg-[#0052CC] text-white py-3 rounded-lg font-semibold hover:bg-blue-700 transition">Masuk</button>
        </form>
        <p class="mt-6 text-center text-sm text-gray-500">Belum punya akun? <a href="/register" class="text-[#0052CC] font-semibold hover:underline">Daftar</a></p>
    </div>

    <script>
        document.getElementById('loginForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            const btn = e.target.querySelector('button');
            btn.innerText = 'Memproses...';
            
            try {
                const res = await fetch('/api/auth/login', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
                    body: JSON.stringify({
                        email: document.getElementById('email').value,
                        password: document.getElementById('password').value
                    })
                });
                
                const data = await res.json();
                if(data.success) {
                    alert('Login berhasil! Token: ' + data.data.token + '\n\nSilakan jalankan Flutter Web App untuk membuka Dashboard.');
                    btn.innerText = 'Masuk';
                } else {
                    alert(data.message || 'Login gagal');
                    btn.innerText = 'Masuk';
                }
            } catch(err) {
                alert('Terjadi kesalahan koneksi.');
                btn.innerText = 'Masuk';
            }
        });
    </script>
</body>
</html>
