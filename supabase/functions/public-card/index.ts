import { adminClient, cors, json } from "../_shared/common.ts";

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response(null, { headers: cors });
  }
  if (request.method !== "POST") {
    return json({ error: "Metode tidak didukung." }, 405);
  }
  const { token: rawToken } = await request.json().catch(() => ({}));
  const token = typeof rawToken === "string" ? rawToken : "";
  if (!/^[a-f0-9]{64}$/.test(token)) {
    return json({ error: "invalid", message: "Tautan kartu tidak dikenal." });
  }
  const admin = adminClient();
  const { data: link, error } = await admin.from("share_links")
    .select("owner_id, expires_at").eq("token", token).maybeSingle();
  if (error) {
    return json(
      { error: "server", message: "Profil belum dapat dimuat." },
      500,
    );
  }
  if (!link) {
    return json({ error: "invalid", message: "Tautan kartu tidak dikenal." });
  }
  if (new Date(link.expires_at).getTime() <= Date.now()) {
    return json({
      error: "expired",
      message: "Tautan kartu sudah kedaluwarsa. Minta QR baru dari pemilik.",
    });
  }
  const { data: account } = await admin.from("accounts").select("status")
    .eq("id", link.owner_id).maybeSingle();
  const { data: card } = await admin.from("cards").select(
    "owner_id, full_name, job_title, company, industry, city, public_email, phone, linkedin, bio, photo_path, is_public",
  ).eq("owner_id", link.owner_id).maybeSingle();
  if (account?.status !== "active" || !card?.is_public) {
    return json({
      error: "hidden",
      message: "Profil ini sedang tidak tersedia.",
    });
  }
  let photoUrl: string | null = null;
  if (card.photo_path) {
    const { data: photo } = await admin.storage.from("card-photos")
      .createSignedUrl(card.photo_path, 3600);
    photoUrl = photo?.signedUrl ?? null;
  }
  return json({
    card: {
      owner_id: card.owner_id,
      full_name: card.full_name,
      job_title: card.job_title,
      company: card.company,
      industry: card.industry,
      city: card.city,
      public_email: card.public_email,
      phone: card.phone,
      linkedin: card.linkedin,
      bio: card.bio,
      photo_url: photoUrl,
    },
  });
});
