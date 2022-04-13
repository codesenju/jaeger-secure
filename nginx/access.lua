local client_id = "jaeger"
local opts = {
    redirect_uri_path = "/redirect_uri",
    accept_none_alg = true,
    discovery = "https://localhost:8443/realms/demo/.well-known/openid-configuration",
    client_id = client_id,
    client_secret = "this_is_a_super_secret_for_jaeger_client",
    -- adammalone.net/post/integrating-nginx-and-keycloak-without-openresty/
    ssl_verify = "no",
    redirect_uri_scheme = "http",
    logout_path = "/logout",
    redirect_after_logout_uri = "https://localhost:8443/realms/demo/protocol/openid-connect/logout?redirect_uri=http://localhost:16686/",
    redirect_after_logout_with_id_token_hint = false,
    session_contents = {id_token=true}
  }
  -- call introspect for OAuth 2.0 Bearer Access Token validation
  local res, err = require("resty.openidc").authenticate(opts)
  if err then
     ngx.status = 403
     ngx.say(err)
     ngx.exit(ngx.HTTP_FORBIDDEN)
  end
     -- RBAC - create client role in jaeger client named 'admin' and assign user to that client role
     -- Error handling
    local x = 0
    function checkRoles ()
        if res.id_token.resource_access.jaeger.roles ~= nil then
                for key,value in ipairs(res.id_token.resource_access.jaeger.roles)
                do
                    if value == "admin" then
                        x = x + 1
                    end
                end
        end
    end
    -- Error handling
    if pcall(checkRoles) then
        -- no errors while running `checkRoles()'
        if x < 1 then
            ngx.redirect("/logout")
        end
    else
        -- `checkRoles()' raised an error: take appropriate actions
    ngx.redirect("/logout")
    end