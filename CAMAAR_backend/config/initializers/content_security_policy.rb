# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header


Rails.application.configure do
  config.content_security_policy do |policy|
    # Permite todas as fontes para uma API que será acessada por diferentes origens
    policy.default_src :self, :https, '*'
    policy.font_src    :self, :https, :data, '*'
    policy.img_src     :self, :https, :data, '*'
    policy.object_src  :none
    policy.script_src  :self, :https, '*'
    policy.style_src   :self, :https, '*'
    
    # Permitir conexões de qualquer origem
    policy.connect_src :self, :https, '*'
    
    # Você pode adicionar um endpoint para relatórios de violação
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Não aplicar a política em modo estrito para API
  # config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  # config.content_security_policy_nonce_directives = %w(script-src style-src)

  # Apenas relatar violações sem forçar a política
  config.content_security_policy_report_only = true
end
