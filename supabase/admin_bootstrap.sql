-- Auto-create Super Admin for FunAging.club
INSERT INTO public.admin_users (email, role)
VALUES ('sanookagingstudio@gmail.com', 'super_admin')
ON CONFLICT(email) DO UPDATE SET role='super_admin';

INSERT INTO public.user_roles (email, role)
VALUES ('sanookagingstudio@gmail.com', 'super_admin')
ON CONFLICT(email) DO UPDATE SET role='super_admin';

INSERT INTO public.fun_portal_users (user_email, portal, role, is_active)
VALUES ('sanookagingstudio@gmail.com', 'hq', 'super_admin', TRUE)
ON CONFLICT(user_email, portal) DO UPDATE SET role='super_admin', is_active=TRUE;
