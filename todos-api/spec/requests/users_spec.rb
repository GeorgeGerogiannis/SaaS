# require 'rails_helper'
#
# RSpec.describe 'Users API', type: :request do
#   let(:user) { build(:user) }
#   let(:headers) { valid_headers.except('Authorization') }
#   let(:valid_attributes) do
#     attributes_for(:user, password_confirmation: user.password)
#   end
#
#   # User signup test suite
#   describe 'POST /signup' do
#     context 'when valid request' do
#       before { post '/signup', params: valid_attributes.to_json, headers: headers }
#
#       it 'creates a new user' do
#         expect(response).to have_http_status(201)
#       end
#
#       it 'returns success message' do
#         expect(json['message']).to match(/Account created successfully/)
#       end
#
#       it 'returns an authentication token' do
#         expect(json['auth_token']).not_to be_nil
#       end
#     end
#
#     context 'when invalid request' do
#       before { post '/signup', params: {}, headers: headers }
#
#       it 'does not create a new user' do
#         expect(response).to have_http_status(422)
#       end
#
#       it 'returns failure message' do
#         expect(json['message'])
#           .to match(/Validation failed: Password can't be blank, Name can't be blank, Email can't be blank, Password digest can't be blank/)
#       end
#     end
#   end
# end


require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  path '/signup' do
    post 'Creates a new user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :signup_params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string },
          password: { type: :string },
          password_confirmation: { type: :string }
        },
        required: [:name, :email, :password]
      }

      response '201', 'user created' do
        let(:user) { build(:user) }
        let(:signup_params) { {
          name: user.name,
          email: user.email,
          password: user.password,
          password_confirmation: user.password
        } }

        run_test! do |response|
          expect(json['message']).to match(/Account created successfully/)
          expect(json['auth_token']).not_to be_nil
        end
      end

      response '422', 'invalid request' do
        let(:signup_params) { {} }

        run_test! do |response|
          expect(json['message']).to match(/Validation failed:/)
        end
      end
    end
  end
end
