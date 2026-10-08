import { createClient } from "npm:@supabase/supabase-js@2";

export const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, apikey, content-type, x-client-info",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
};

export const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });

export const adminClient = () =>
  createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { autoRefreshToken: false, persistSession: false } },
  );

export async function actor(request: Request) {
  const bearer = request.headers.get("Authorization");
  if (!bearer?.startsWith("Bearer ")) return null;
  const admin = adminClient();
  const { data, error } = await admin.auth.getUser(bearer.slice(7));
  if (error || !data.user) return null;
  const { data: account } = await admin.from("accounts")
    .select("id, role, status, must_change_password")
    .eq("id", data.user.id).single();
  return account ?? null;
}
