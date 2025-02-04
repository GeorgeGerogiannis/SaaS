# require 'rails_helper'
#
# RSpec.describe 'Todos API', type: :request do
#   # add todos owner
#   let(:user) { create(:user) }
#   let!(:todos) { create_list(:todo, 10, created_by: user.id) }
#   let(:todo_id) { todos.first.id }
#   # authorize request
#   let(:headers) { valid_headers }
#
#   # Test suite for GET /todos
#   describe 'GET /todos' do
#     # make HTTP get request before each example
#     before { get '/todos', params: {}, headers: headers }
#
#     it 'returns todos' do
#       # Note `json` is a custom helper to parse JSON responses
#       expect(json).not_to be_empty
#       expect(json.size).to eq(10)
#     end
#
#     it 'returns status code 200' do
#       expect(response).to have_http_status(200)
#     end
#   end
#
#   # Test suite for GET /todos/:id
#   describe 'GET /todos/:id' do
#     before { get "/todos/#{todo_id}", params: {}, headers: headers }
#
#     context 'when the record exists' do
#       it 'returns the todo' do
#         expect(json).not_to be_empty
#         expect(json['id']).to eq(todo_id)
#       end
#
#       it 'returns status code 200' do
#         expect(response).to have_http_status(200)
#       end
#     end
#
#     context 'when the record does not exist' do
#       let(:todo_id) { 100 }
#
#       it 'returns status code 404' do
#         expect(response).to have_http_status(404)
#       end
#
#       it 'returns a not found message' do
#         expect(response.body).to match(/Couldn't find Todo/)
#       end
#     end
#   end
#
#   # Test suite for POST /todos
#   describe 'POST /todos' do
#     # valid payload
#     let(:valid_attributes) { { title: 'Learn Elm', created_by: user.id.to_s }.to_json }
#
#     context 'when the request is valid' do
#       before { post '/todos', params: valid_attributes, headers: headers }
#
#       it 'creates a todo' do
#         expect(json['title']).to eq('Learn Elm')
#       end
#
#       it 'returns status code 201' do
#         expect(response).to have_http_status(201)
#       end
#     end
#
#     context 'when the request is invalid' do
#       let(:invalid_attributes) { { title: nil }.to_json }
#       before { post '/todos', params: invalid_attributes, headers: headers }
#
#       it 'returns status code 422' do
#         expect(response).to have_http_status(422)
#       end
#
#       it 'returns a validation failure message' do
#         expect(json['message'])
#           .to match(/Validation failed: Title can't be blank/)
#       end
#     end
#   end
#
#   # Test suite for PUT /todos/:id
#   describe 'PUT /todos/:id' do
#     let(:valid_attributes) { { title: 'Shopping' }.to_json }
#
#     context 'when the record exists' do
#       before { put "/todos/#{todo_id}", params: valid_attributes, headers: headers }
#
#       it 'updates the record' do
#         expect(response.body).to be_empty
#       end
#
#       it 'returns status code 204' do
#         expect(response).to have_http_status(204)
#       end
#     end
#   end
#
#   # Test suite for DELETE /todos/:id
#   describe 'DELETE /todos/:id' do
#     before { delete "/todos/#{todo_id}", params: {}, headers: headers }
#
#     it 'returns status code 204' do
#       expect(response).to have_http_status(204)
#     end
#   end
# end


require 'swagger_helper'

RSpec.describe 'Todos API', type: :request do
  path '/todos' do
    get 'Retrieves all todos' do
      tags 'Todos'
      produces 'application/json'
      security [jwt_auth: []]

      response '200', 'todos found' do
        let(:user) { create(:user) }
        let!(:todos) { create_list(:todo, 10, created_by: user.id) }
        let(:Authorization) { valid_headers['Authorization'] }

        run_test! do |response|
          expect(json.size).to eq(10)
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'invalid_token' }

        run_test! do |response|
          expect(response.status).to eq(401)
          expect(json['message']).to be_present
        end
      end
    end

    post 'Creates a todo' do
      tags 'Todos'
      consumes 'application/json'
      produces 'application/json'
      security [jwt_auth: []]

      parameter name: :todo, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          created_by: { type: :string }
        },
        required: [:title]
      }

      response '201', 'todo created' do
        let(:user) { create(:user) }
        let(:todo) { { title: 'Learn Elm', created_by: user.id.to_s } }
        let(:Authorization) { valid_headers['Authorization'] }

        run_test! do |response|
          expect(json['title']).to eq('Learn Elm')
        end
      end

      response '401', 'unauthorized' do
        let(:todo) { { title: 'Learn Elm' } }
        let(:Authorization) { 'invalid_token' }

        run_test! do |response|
          expect(response.status).to eq(401)
          expect(json['message']).to be_present
        end
      end

      response '422', 'invalid request' do
        let(:user) { create(:user) }
        let(:todo) { { title: nil } }
        let(:Authorization) { valid_headers['Authorization'] }

        run_test! do |response|
          expect(json['message']).to match(/Validation failed: Title can't be blank/)
        end
      end
    end
  end

  path '/todos/{id}' do
    parameter name: :id, in: :path, type: :string

    get 'Retrieves a todo' do
      tags 'Todos'
      produces 'application/json'
      security [jwt_auth: []]

      response '200', 'todo found' do
        let(:user) { create(:user) }
        let!(:todo) { create(:todo, created_by: user.id) }
        let(:id) { todo.id }
        let(:Authorization) { valid_headers['Authorization'] }

        run_test! do |response|
          expect(json['id']).to eq(todo.id)
        end
      end

      response '401', 'unauthorized' do
        let(:id) { 'any_id' }
        let(:Authorization) { 'invalid_token' }

        run_test! do |response|
          expect(response.status).to eq(401)
          expect(json['message']).to be_present
        end
      end

      response '404', 'todo not found' do
        let(:user) { create(:user) }
        let(:id) { 'invalid' }
        let(:Authorization) { valid_headers['Authorization'] }

        run_test! do |response|
          expect(response.body).to match(/Couldn't find Todo/)
        end
      end
    end

    put 'Updates a todo' do
      tags 'Todos'
      consumes 'application/json'
      security [jwt_auth: []]

      parameter name: :todo, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string }
        }
      }

      response '204', 'todo updated' do
        let(:user) { create(:user) }
        let!(:todo) { create(:todo, created_by: user.id) }
        let(:id) { todo.id }
        let(:todo_params) { { title: 'Shopping' } }
        let(:Authorization) { valid_headers['Authorization'] }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:id) { 'any_id' }
        let(:todo) { { title: 'Shopping' } }
        let(:Authorization) { 'invalid_token' }

        run_test! do |response|
          expect(response.status).to eq(401)
          expect(json['message']).to be_present
        end
      end
    end

    delete 'Deletes a todo' do
      tags 'Todos'
      security [jwt_auth: []]

      response '204', 'todo deleted' do
        let(:user) { create(:user) }
        let!(:todo) { create(:todo, created_by: user.id) }
        let(:id) { todo.id }
        let(:Authorization) { valid_headers['Authorization'] }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:id) { 'any_id' }
        let(:Authorization) { 'invalid_token' }

        run_test! do |response|
          expect(response.status).to eq(401)
          expect(json['message']).to be_present
        end
      end
    end
  end
end
