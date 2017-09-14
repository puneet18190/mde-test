shared_examples 'after saving a video with a valid not converted media' do
  it 'creates the video cover' do
    expect(File.exist?(record.media.path(:cover))).to be true
  end

  it 'creates the video thumb' do
    expect(File.exist?(record.media.path(:thumb))).to be true
  end
end