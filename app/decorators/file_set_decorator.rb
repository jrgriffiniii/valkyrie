# frozen_string_literal: true
class FileSetDecorator < ApplicationDecorator
  delegate_all

  def download_id
    id
  end
end
