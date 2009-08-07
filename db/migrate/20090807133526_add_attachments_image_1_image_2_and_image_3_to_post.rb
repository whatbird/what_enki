class AddAttachmentsImage1Image2AndImage3ToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :image_1_file_name, :string
    add_column :posts, :image_1_content_type, :string
    add_column :posts, :image_1_file_size, :integer
    add_column :posts, :image_1_updated_at, :datetime
    add_column :posts, :image_2_file_name, :string
    add_column :posts, :image_2_content_type, :string
    add_column :posts, :image_2_file_size, :integer
    add_column :posts, :image_2_updated_at, :datetime
    add_column :posts, :image_3_file_name, :string
    add_column :posts, :image_3_content_type, :string
    add_column :posts, :image_3_file_size, :integer
    add_column :posts, :image_3_updated_at, :datetime
  end

  def self.down
    remove_column :posts, :image_1_file_name
    remove_column :posts, :image_1_content_type
    remove_column :posts, :image_1_file_size
    remove_column :posts, :image_1_updated_at
    remove_column :posts, :image_2_file_name
    remove_column :posts, :image_2_content_type
    remove_column :posts, :image_2_file_size
    remove_column :posts, :image_2_updated_at
    remove_column :posts, :image_3_file_name
    remove_column :posts, :image_3_content_type
    remove_column :posts, :image_3_file_size
    remove_column :posts, :image_3_updated_at
  end
end
