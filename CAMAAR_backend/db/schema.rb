# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_11_030000) do
  create_table "admins", force: :cascade do |t|
    t.integer "registration"
    t.string "name"
    t.string "email"
    t.string "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "alternativas", force: :cascade do |t|
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "departamentos", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "abreviation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "disciplinas", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "formularios", force: :cascade do |t|
    t.string "name"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questoes", force: :cascade do |t|
    t.string "enunciado"
    t.integer "templates_id", null: false
    t.integer "formularios_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["formularios_id"], name: "index_questoes_on_formularios_id"
    t.index ["templates_id"], name: "index_questoes_on_templates_id"
  end

  create_table "resposta", force: :cascade do |t|
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "templates", force: :cascade do |t|
    t.string "content"
    t.integer "admin_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_templates_on_admin_id"
  end

  create_table "turma_alunos", force: :cascade do |t|
    t.integer "turma_id", null: false
    t.integer "aluno_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aluno_id"], name: "index_turma_alunos_on_aluno_id"
    t.index ["turma_id"], name: "index_turma_alunos_on_turma_id"
  end

  create_table "turmas", force: :cascade do |t|
    t.string "code"
    t.integer "number"
    t.string "semester"
    t.string "time"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "registration"
    t.string "name"
    t.string "email"
    t.string "password"
    t.integer "forms_answered", default: 0
    t.string "major"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "questoes", "formularios", column: "formularios_id"
  add_foreign_key "questoes", "templates", column: "templates_id"
  add_foreign_key "templates", "admins"
end
