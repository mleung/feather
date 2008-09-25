migration 1, :create_ma_users_table do
  up do
    create_table :<%= table_name %> do
      column :id,                         Integer,  :serial   => true
      column :login,                      String,   :nullable? => false
      column :email,                      String,   :nullable? => false
      column :created_at,                 DateTime
      column :updated_at,                 DateTime
      column :activated_at,               DateTime
      column :activation_code,            String
      column :crypted_password,           String
      column :salt,                       String
      column :remember_token_expires_at,  DateTime
      column :remember_token,             String
      column :password_reset_key,         String
    end
  end
  down do
    drop_table :<%= table_name %>
  end
end