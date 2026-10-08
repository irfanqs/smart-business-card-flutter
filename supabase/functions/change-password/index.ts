import { actor, adminClient, cors, json } from "../_shared/common.ts";

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response(null, { headers: cors });
  }
  if (request.method !== "POST") {
    return json({ error: "Metode tidak didukung." }, 405);
  }
  const account = await actor(request);
  if (!account || account.status !== "active") {
    return json({ error: "Akses ditolak." }, 403);
  }
  const { password } = await request.json().catch(() => ({}));
  if (typeof password !== "string" || password.length < 8) {
    return json({ error: "Sandi minimal 8 karakter." }, 400);
  }
  const admin = adminClient();
  const { error } = await admin.auth.admin.updateUserById(account.id, {
    password,
  });
  if (error) {
    // Penolakan validasi dari Auth (sandi lemah/sama) dikembalikan apa adanya.
    const status = error.status && error.status < 500 ? 400 : 500;
    return json({
      error: status === 400 ? error.message : "Sandi belum dapat diubah.",
    }, status);
  }
  const { error: flagError } = await admin.from("accounts")
    .update({ must_change_password: false }).eq("id", account.id);
  if (flagError) {
    return json({ error: "Status sandi belum dapat disimpan." }, 500);
  }
  return json({ ok: true });
});
