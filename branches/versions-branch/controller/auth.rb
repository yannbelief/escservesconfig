
class AuthController < EscController
    map('/auth')

  def index
    'Public Info'
  end

  def secret
    check_auth
    'Secret Info'
  end

end

