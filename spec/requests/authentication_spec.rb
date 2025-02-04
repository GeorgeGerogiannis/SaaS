# require 'rails_helper'
#
# RSpec.describe 'Authentication', type: :request do
#   # Authentication test suite
#   describe 'POST /auth/login' do
#     # create test user
#     let!(:user) { create(:user) }
#     # set headers for authorization
#     let(:headers) { valid_headers.except('Authorization') }
#     # set test valid and invalid credentials
#     let(:valid_credentials) do
#       {
#         email: user.email,
#         password: user.password
#       }.to_json
#     end
#     let(:invalid_credentials) do
#       {
#         email: Faker::Internet.email,
#         password: Faker::Internet.password
#       }.to_json
#     end
#
#     # set request.headers to our custom headers
#     # before { allow(request).to receive(:headers).and_return(headers) }
#
#     # returns auth token when request is valid
#     context 'When request is valid' do
#       before { post '/auth/login', params: valid_credentials, headers: headers }
#
#       it 'returns an authentication token' do
#         expect(json['auth_token']).not_to be_nil
#       end
#     end
#
#     # returns failure message when request is invalid
#     context 'When request is invalid' do
#       before { post '/auth/login', params: invalid_credentials, headers: headers }
#
#       it 'returns a failure message' do
#         expect(json['message']).to match(/Invalid credentials/)
#       end
#     end
#   end
# end


require 'swagger_helper'

RSpec.describe 'Authentication API', type: :request do
  path '/auth/login' do
    post 'Authenticates user and returns token' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: [:email, :password]
      }

      response '200', 'user authenticated' do
        let(:user) { create(:user) }
        let(:credentials) { { email: user.email, password: user.password } }

        run_test! do |response|
          expect(json['auth_token']).not_to be_nil
        end
      end

      response '401', 'invalid credentials' do
        let(:credentials) { { email: Faker::Internet.email, password: Faker::Internet.password } }

        run_test! do |response|
          expect(json['message']).to match(/Invalid credentials/)
        end
      end
    end
  end
end
