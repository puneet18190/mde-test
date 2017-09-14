shared_examples 'after saving an audio or a video with a valid not converted media' do
  let(:public_relative_folder) { "/media_elements/#{media_type}s/test/#{record.id}" }
  let(:folder)                 { "#{Rails.root}/public#{public_relative_folder}" }
  let(:name)                   do
    filename = "tmp-valid-#{media_type}"
    return filename unless short_media_filename_size
    
    filename.slice 0, short_media_filename_size
  end
  let(:url_without_extension)  { "#{public_relative_folder}/#{name}" }
  let(:path_without_extension) { "#{folder}/#{name}" }
  let(:media_formats)          { "MESS::#{media_type.upcase}_FORMATS".constantize }
  let(:info)                   { media_formats.map{ |f| [f, Media::Info.new(record.media.path(f))] }.to_h }
  let(:metadata)               { media_formats.map{ |f| [:"#{f}_duration", info[f].duration] }.to_h.merge(creation_mode: :uploaded) }

  it 'resets model rename_media attribute' do
    expect(record.rename_media).to_not be true
  end

  it 'resets model skip_conversion attribute' do
    expect(record.skip_conversion).to_not be true
  end

  it 'sets the expected metadata' do
    expect(record.metadata.marshal_dump).to eq metadata
  end

  it 'sets the expected [:media] value' do
    expect(record[:media]).to match MESS::FILENAME_RE.call(name)
  end

  it 'has the expected to_s' do
    expect(record.media.to_s).to match MESS::FILENAME_RE.call(url_without_extension)
  end

  it 'has the expected urls' do
    urls.each do |format, filename_re_arguments|
      expect(record.media.url(format)).to match MESS::FILENAME_RE.call(*filename_re_arguments)
    end
  end

  it 'has the expected paths' do
    paths.each do |format, filename_re_arguments|
      expect(record.media.path(format)).to match MESS::FILENAME_RE.call(*filename_re_arguments)
    end
  end

  it 'is marked as uploaded' do
    expect(record.uploaded?).to be true
  end

  it 'creates valid records' do
    expect{ info }.to_not raise_error
  end
end