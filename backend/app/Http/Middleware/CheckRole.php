<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckRole
{
    /**
     * Handle an incoming request.
     * Cek apakah user yang login memiliki role yang diizinkan.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     * @param  string[] ...$roles
     */
    public function handle(Request $request, Closure $next, ...$roles): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        // Ambil array nama role yang dimiliki user dari relasi pivot table role_user
        $userRoles = $user->roles->pluck('name')->toArray();

        // Jika user adalah superadmin, selalu beri akses (opsional)
        if (in_array('superadmin', $userRoles)) {
            return $next($request);
        }

        // Cek irisan array: apakah salah satu role user ada di dalam daftar role yang diperbolehkan di parameter
        $hasAccess = count(array_intersect($userRoles, $roles)) > 0;

        if (!$hasAccess) {
            return response()->json([
                'success' => false,
                'message' => 'Forbidden. Anda tidak memiliki akses ke fitur ini (Dibutuhkan role: ' . implode(',', $roles) . ')'
            ], 403);
        }

        return $next($request);
    }
}
