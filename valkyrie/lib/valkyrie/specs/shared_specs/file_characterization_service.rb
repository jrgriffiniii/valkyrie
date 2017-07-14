# frozen_string_literal: true

RSpec.shared_examples 'a Valkyrie::FileCharacterizationService' do
  before do
    raise 'valid_file must be set with `let(:valid_file)`' unless
      defined? valid_file
    raise 'storage_adapter must be set with `let(:storage_adapter)`' unless
      defined? storage_adapter
    raise 'file_characterization_service must be set with `let(:file_characterization_service)`' unless
      defined? file_characterization_service
  end

  subject { file_characterization_service.new(file: valid_file, storage_adapter: storage_adapter) }

  it { is_expected.to respond_to(:characterize).with(0).arguments }
  it 'returns a file' do
    expect(subject.characterize).to be_a(Valkyrie::StorageAdapter::File)
  end

  describe '#valid?' do
    context 'when given a file it handles' do
      it { is_expected.to be_valid }
    end
  end

  it 'takes a file and a storage adapter as arguments' do
    obj = file_characterization_service.new(file: valid_file, storage_adapter: storage_adapter)
    expect(obj.file).to eq valid_file
    expect(obj.storage_adapter).to eq storage_adapter
  end
end
