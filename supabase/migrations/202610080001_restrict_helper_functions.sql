-- RLS helper functions run through policies; anonymous callers do not need RPC access.
revoke execute on function public.can_use_app() from public, anon;
revoke execute on function public.relation_owned_by_me(uuid) from public, anon;
revoke execute on function public.handle_new_user() from public, anon, authenticated;
