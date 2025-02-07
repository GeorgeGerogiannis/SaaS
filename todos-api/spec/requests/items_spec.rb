# require 'rails_helper'
#
# RSpec.describe 'Items API' do
#   # Initialize the test data
#   let(:user) { create(:user) }
#   let!(:todo) { create(:todo, created_by: user.id) }
#   let!(:items) { create_list(:item, 20, todo_id: todo.id) }
#   let(:todo_id) { todo.id }
#   let(:id) { items.first.id }
#   let(:headers) { valid_headers }
#
#   # Test suite for GET /todos/:todo_id/items
#   describe 'GET /todos/:todo_id/items' do
#     before { get "/todos/#{todo_id}/items", params: {}, headers: headers }
#
#     context 'when todo exists' do
#       it 'returns status code 200' do
#         expect(response).to have_http_status(200)
#       end
#
#       it 'returns all todo items' do
#         expect(json.size).to eq(20)
#       end
#     end
#
#     context 'when todo does not exist' do
#       let(:todo_id) { 0 }
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
#   # Test suite for GET /todos/:todo_id/items/:id
#   describe 'GET /todos/:todo_id/items/:id' do
#     before { get "/todos/#{todo_id}/items/#{id}", params: {}, headers: headers }
#
#     context 'when todo item exists' do
#       it 'returns status code 200' do
#         expect(response).to have_http_status(200)
#       end
#
#       it 'returns the item' do
#         expect(json['id']).to eq(id)
#       end
#     end
#
#     context 'when todo item does not exist' do
#       let(:id) { 0 }
#
#       it 'returns status code 404' do
#         expect(response).to have_http_status(404)
#       end
#
#       it 'returns a not found message' do
#         expect(response.body).to match(/Couldn't find Item/)
#       end
#     end
#   end
#
#   # Test suite for PUT /todos/:todo_id/items
#   describe 'POST /todos/:todo_id/items' do
#     let(:valid_attributes) { { name: 'Visit Narnia', done: false }.to_json }
#
#     context 'when request attributes are valid' do
#       before do
#         post "/todos/#{todo_id}/items", params: valid_attributes, headers: headers
#       end
#
#       it 'returns status code 201' do
#         expect(response).to have_http_status(201)
#       end
#     end
#
#     context 'when an invalid request' do
#       before { post "/todos/#{todo_id}/items", params: {}, headers: headers }
#
#       it 'returns status code 422' do
#         expect(response).to have_http_status(422)
#       end
#
#       it 'returns a failure message' do
#         expect(response.body).to match(/Validation failed: Name can't be blank/)
#       end
#     end
#   end
#
#   # Test suite for PUT /todos/:todo_id/items/:id
#   describe 'PUT /todos/:todo_id/items/:id' do
#     let(:valid_attributes) { { name: 'Mozart' }.to_json }
#
#     before do
#       put "/todos/#{todo_id}/items/#{id}", params: valid_attributes, headers: headers
#     end
#
#     context 'when item exists' do
#       it 'returns status code 204' do
#         expect(response).to have_http_status(204)
#       end
#
#       it 'updates the item' do
#         updated_item = Item.find(id)
#         expect(updated_item.name).to match(/Mozart/)
#       end
#     end
#
#     context 'when the item does not exist' do
#       let(:id) { 0 }
#
#       it 'returns status code 404' do
#         expect(response).to have_http_status(404)
#       end
#
#       it 'returns a not found message' do
#         expect(response.body).to match(/Couldn't find Item/)
#       end
#     end
#   end
#
#   # Test suite for DELETE /todos/:id
#   describe 'DELETE /todos/:id' do
#     before { delete "/todos/#{todo_id}/items/#{id}", params: {}, headers: headers }
#
#     it 'returns status code 204' do
#       expect(response).to have_http_status(204)
#     end
#   end
# end


require 'swagger_helper'

RSpec.describe 'Items API', type: :request do
  path '/todos/{todo_id}/items' do
    parameter name: :todo_id, in: :path, type: :string

    get 'Retrieves all items for a todo' do
      tags 'Items'
      produces 'application/json'
      security [jwt_auth: []]

      response '200', 'items found' do
        let(:user) { create(:user) }
        let!(:todo) { create(:todo, created_by: user.id) }
        let!(:items) { create_list(:item, 20, todo_id: todo.id) }
        let(:todo_id) { todo.id }
        let(:Authorization) { valid_headers['Authorization'] }

        run_test! do |response|
          expect(json.size).to eq(20)
        end
      end

      response '401', 'unauthorized' do
        let(:todo_id) { 'any_id' }
        let(:Authorization) { 'invalid_token' }

        run_test! do |response|
          expect(response.status).to eq(401)
          expect(json['message']).to be_present
        end
      end

      response '404', 'todo not found' do
        let(:user) { create(:user) }
        let(:todo_id) { 'invalid' }
        let(:Authorization) { valid_headers['Authorization'] }

        run_test! do |response|
          expect(response.body).to match(/Couldn't find Todo/)
        end
      end
    end

    post 'Creates an item for a todo' do
      tags 'Items'
      consumes 'application/json'
      produces 'application/json'
      security [jwt_auth: []]

      parameter name: :item, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          done: { type: :boolean }
        },
        required: [:name]
      }

      response '201', 'item created' do
        let(:user) { create(:user) }
        let!(:todo) { create(:todo, created_by: user.id) }
        let(:todo_id) { todo.id }
        let(:item) { { name: 'Visit Narnia', done: false } }
        let(:Authorization) { valid_headers['Authorization'] }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:todo_id) { 'any_id' }
        let(:item) { { name: nil } }
        let(:Authorization) { 'invalid_token' }

        run_test! do |response|
          expect(response.status).to eq(401)
          expect(json['message']).to be_present
        end
      end

      response '422', 'invalid request' do
        let(:user) { create(:user) }
        let!(:todo) { create(:todo, created_by: user.id) }
        let(:todo_id) { todo.id }
        let(:item) { { name: nil } }
        let(:Authorization) { valid_headers['Authorization'] }

        run_test! do |response|
          expect(response.body).to match(/Validation failed: Name can't be blank/)
        end
      end
    end
  end

  path '/todos/{todo_id}/items/{id}' do
    parameter name: :todo_id, in: :path, type: :string
    parameter name: :id, in: :path, type: :string

    get 'Retrieves an item' do
      tags 'Items'
      produces 'application/json'
      security [jwt_auth: []]

      response '200', 'item found' do
        let(:user) { create(:user) }
        let!(:todo) { create(:todo, created_by: user.id) }
        let!(:item) { create(:item, todo_id: todo.id) }
        let(:todo_id) { todo.id }
        let(:id) { item.id }
        let(:Authorization) { valid_headers['Authorization'] }

        run_test! do |response|
          expect(json['id']).to eq(item.id)
        end
      end

      response '401', 'unauthorized' do
        let(:todo_id) { 'any_id' }
        let(:id) { 'any_id' }
        let(:Authorization) { 'invalid_token' }

        run_test! do |response|
          expect(response.status).to eq(401)
          expect(json['message']).to be_present
        end
      end

      response '404', 'item not found' do
        let(:user) { create(:user) }
        let!(:todo) { create(:todo, created_by: user.id) }
        let(:todo_id) { todo.id }
        let(:id) { 'invalid' }
        let(:Authorization) { valid_headers['Authorization'] }

        run_test! do |response|
          expect(response.body).to match(/Couldn't find Item/)
        end
      end
    end

    put 'Updates an item' do
      tags 'Items'
      consumes 'application/json'
      security [jwt_auth: []]

      parameter name: :item, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          done: { type: :boolean }
        }
      }

      response '204', 'item updated' do
        let(:user) { create(:user) }
        let!(:todo) { create(:todo, created_by: user.id) }
        let!(:item) { create(:item, todo_id: todo.id) }
        let(:todo_id) { todo.id }
        let(:id) { item.id }
        let(:item_params) { { name: 'Mozart' } }
        let(:Authorization) { valid_headers['Authorization'] }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:todo_id) { 'any_id' }
        let(:id) { 'any_id' }
        let(:item) { { name: 'Mozart' } }
        let(:Authorization) { 'invalid_token' }

        run_test! do |response|
          expect(response.status).to eq(401)
          expect(json['message']).to be_present
        end
      end
    end

    delete 'Deletes an item' do
      tags 'Items'
      security [jwt_auth: []]

      response '204', 'item deleted' do
        let(:user) { create(:user) }
        let!(:todo) { create(:todo, created_by: user.id) }
        let!(:item) { create(:item, todo_id: todo.id) }
        let(:todo_id) { todo.id }
        let(:id) { item.id }
        let(:Authorization) { valid_headers['Authorization'] }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:todo_id) { 'any_id' }
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
