import { actor, adminClient, cors, json } from "../_shared/common.ts";

function temporaryPassword() {
  const alphabet =
    "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%";
  const bytes = crypto.getRandomValues(new Uint8Array(24));
  return Array.from(bytes, (n) => alphabet[n % alphabet.length]).join("");
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response(null, { headers: cors });
  }
  const account = await actor(request);
  if (!account || account.role !== "admin" || account.status !== "active") {
    return json({ error: "Akses admin ditolak." }, 403);
  }
  const admin = adminClient();
  if (request.method !== "POST") {
    return json({ error: "Metode tidak didukung." }, 405);
  }
  const { action, userId } = await request.json().catch(() => ({}));
  if (action === "list") {
    const { data, error } = await admin.from("accounts")
      .select("id, email, status, created_at, must_change_password")
      .eq("role", "user").order("created_at", { ascending: false });
    if (error) return json({ error: "Daftar akun belum dapat dimuat." }, 500);
    return json({ users: data });
  }
  if (typeof userId !== "string") {
    return json({ error: "Akun tidak valid." }, 400);
  }
  const { data: target } = await admin.from("accounts").select(
    "id, role, status",
  )
    .eq("id", userId).maybeSingle();
  if (!target || target.role !== "user") {
    return json({ error: "Akun pengguna tidak ditemukan." }, 404);
  }
  if (action === "disable" || action === "enable") {
    const status = action === "disable" ? "disabled" : "active";
    const { error } = await admin.from("accounts").update({ status }).eq(
      "id",
      userId,
    );
    if (error) return json({ error: "Status akun belum dapat disimpan." }, 500);
    const { error: banError } = await admin.auth.admin.updateUserById(userId, {
      ban_duration: action === "disable" ? "876000h" : "none",
    });
    if (banError) {
      await admin.from("accounts").update({ status: target.status }).eq(
        "id",
        userId,
      );
      return json({ error: "Status akun belum dapat diubah sepenuhnya." }, 500);
    }
    return json({ ok: true });
  }
  if (action === "reset") {
    const password = temporaryPassword();
    const { error: flagError } = await admin.from("accounts")
      .update({ must_change_password: true }).eq("id", userId);
    if (flagError) {
      return json({ error: "Status sandi belum dapat disimpan." }, 500);
    }
    const { error } = await admin.auth.admin.updateUserById(userId, {
      password,
    });
    if (error) {
      await admin.from("accounts").update({ must_change_password: false }).eq(
        "id",
        userId,
      );
      return json({ error: "Sandi belum dapat diatur ulang." }, 500);
    }
    return json({ password });
  }
  return json({ error: "Tindakan tidak dikenal." }, 400);
});
