require 'spec_helper'

module Media
  module Video
    describe Uploader do
      def media_folder
        @media_folder ||= Rails.root.join('spec/support/samples')
      end

      def media_without_extension
        @media_without_extension ||= media_folder.join('con verted').to_s
      end

      def valid_media_filename
        @valid_media_filename ||= Pathname 'valid video.flv'
      end

      def tmp_valid_media_filename
        @tmp_valid_media_filename ||= Pathname "tmp.#{valid_media_filename}"
      end

      def valid_media_path
        @valid_media_path ||= media_folder.join(valid_media_filename).to_s
      end

      def tmp_valid_media_path
        @tmp_valid_media_path ||= media_folder.join(tmp_valid_media_filename).to_s
      end

      def media_file
        @media_file ||= File.open(tmp_valid_media_path)
      end

      def media_uploaded
        @media_uploaded ||= ActionDispatch::Http::UploadedFile.new(filename: File.basename(tmp_valid_media_path), tempfile: File.open(tmp_valid_media_path))
      end
      
      def media_hash
        @media_hash ||= { filename: tmp_valid_media_filename.basename(tmp_valid_media_filename.extname).to_s,
                          mp4: "#{media_without_extension}.mp4", 
                          webm: "#{media_without_extension}.webm" }
      end

      def media_hash_full
        @media_hash_full ||= media_hash.merge( mp4_duration:  Info.new(media_hash[:mp4]).duration            ,
                                               webm_duration: Info.new(media_hash[:webm]).duration           ,
                                               cover:         media_folder.join('con verted cover.jpg').to_s ,
                                               thumb:         media_folder.join('con verted thumb.jpg').to_s )
      end

      # 1 is the underscore character size, since the filename suffix is "_#{filename_token}"
      def minimum_media_filename_size
        1 + record.filename_token.size + described_class.superclass::PROCESSED_FILENAME_MAX_EXTENSION_SIZE_DOT_INCLUDED
      end

      def short_media_filename_size
        nil
      end

      def set_model_max_media_column_size
        @previous_max_media_column_size_value = ::Video.max_media_column_size
        ::Video.max_media_column_size = minimum_media_filename_size + short_media_filename_size
      end

      def reset_model_max_media_column_size
        ::Video.max_media_column_size = @previous_max_media_column_size_value
      end

      let(:media_type) { 'video' }
      let(:urls)       { { mp4:   [ url_without_extension, ".mp4"  ], 
                           webm:  [ url_without_extension, ".webm" ],
                           cover: [ "#{public_relative_folder}/cover_#{name}", ".jpg" ], 
                           thumb: [ "#{public_relative_folder}/thumb_#{name}", ".jpg" ] } }
      let(:paths)      { { mp4:   [ path_without_extension, ".mp4"  ], 
                           webm:  [ path_without_extension, ".webm" ],
                           cover: [ "#{folder}/cover_#{name}", ".jpg" ], 
                           thumb: [ "#{folder}/thumb_#{name}", ".jpg" ] } }

      describe 'saving the associated model' do
        before(:all) do
          FileUtils.cp valid_media_path, tmp_valid_media_path
          ['public/media_elements/videos/test', 'tmp/media/video/editing/conversions/test'].each do |folder|
            FileUtils.rm_rf Rails.root.join(folder)
          end
        end
        
        context 'with a File', slow: true do
          def record
            @record ||= ::Video.new(title: 'title', description: 'description', tags: 'a,b,c,d,e', media: media_file, user: User.admin)
          end
          
          context 'after saving' do
            before(:all) do
              record.save!
              record.reload
            end

            include_examples 'after saving an audio or a video with a valid not converted media'
            include_examples 'after saving a video with a valid not converted media'
          end

          context 'when the filename exceeds the maximum filename size limit' do
            def short_media_filename_size
              5
            end

            context 'after saving' do
              before(:all) do
                set_model_max_media_column_size
                record.save!
                record.reload
              end

              include_examples 'after saving an audio or a video with a valid not converted media'
              include_examples 'after saving a video with a valid not converted media'

              after(:all) { reset_model_max_media_column_size }
            end
          end
        end

        context 'with a ActionDispatch::Http::UploadedFile', slow: true do
          def record
            @record ||= ::Video.new(title: 'title', description: 'description', tags: 'a,b,c,d,e', media: media_uploaded, user: User.admin)
          end

          context 'after saving' do
            before(:all) do
              record.save!
              record.reload
            end

            include_examples 'after saving an audio or a video with a valid not converted media'
            include_examples 'after saving a video with a valid not converted media'
          end

          context 'when the filename exceeds the maximum filename size limit' do
            def short_media_filename_size
              5
            end

            context 'after saving' do
              before(:all) do
                set_model_max_media_column_size
                record.save!
                record.reload
              end

              include_examples 'after saving an audio or a video with a valid not converted media'
              include_examples 'after saving a video with a valid not converted media'

              after(:all) { reset_model_max_media_column_size }
            end
          end
        end

        context 'with a Hash' do
          context 'without durations and version paths' do
            def record
              @record ||= ::Video.new(title: 'title', description: 'description', tags: 'a,b,c,d,e', media: media_hash, user: User.admin)
            end

            context 'after saving' do
              before(:all) { record.save! }

              include_examples 'after saving an audio or a video with a valid not converted media'
              include_examples 'after saving a video with a valid not converted media'
            end

            context 'when the filename exceeds the maximum filename size limit' do
              def short_media_filename_size
                5
              end

              context 'after saving' do
                before(:all) do
                  set_model_max_media_column_size
                  record.save!
                end

                include_examples 'after saving an audio or a video with a valid not converted media'
                include_examples 'after saving a video with a valid not converted media'

                after(:all) { reset_model_max_media_column_size }
              end
            end
          end

          context 'with durations and version paths' do
            def record
              @record ||= ::Video.new(title: 'title', description: 'description', tags: 'a,b,c,d,e', media: media_hash_full, user: User.admin)
            end

            before(:all) { record }

            it "uses metadata durations provided by the hash" do
              expect(Media::Info).to_not receive(:new)
              record.save!
            end

            context 'after saving' do
              def record
                @record ||= ::Video.new(title: 'title', description: 'description', tags: 'a,b,c,d,e', media: media_hash_full, user: User.admin)
              end

              before(:all) { record.save! }

              include_examples 'after saving an audio or a video with a valid not converted media'
              include_examples 'after saving a video with a valid not converted media'
            end

            context 'when the filename exceeds the maximum filename size limit' do
              def short_media_filename_size
                5
              end

              context 'after saving' do
                before(:all) do
                  @record = nil
                  set_model_max_media_column_size
                  record.save!
                end

                include_examples 'after saving an audio or a video with a valid not converted media'
                include_examples 'after saving a video with a valid not converted media'

                after(:all) { reset_model_max_media_column_size }
              end
            end
          end
        end
        
        after(:all) do
          FileUtils.rm tmp_valid_media_path if File.exists? tmp_valid_media_path
        end
      end

      describe 'validations' do

        subject { ::Video.new(title: 'title', description: 'description', tags: 'a,b,c,d,e', media: media){ |v| v.user = User.admin }.valid? }

        shared_examples 'when media is a not converted video' do
          context 'when is a valid video' do
            let(:path) { valid_media_path }
            it { expect(subject).to be true }
          end

          context 'when filename is blank' do
            let(:path) { media_folder.join '.flv' }
            it { expect(subject).to be false }
          end

          context 'when the extension is not valid' do
            let(:path) { media_folder.join 'valid video.php' }
            it { expect(subject).to be false }
          end

          context 'when is an invalid video' do
            let(:path) { media_folder.join 'invalid video.flv' }
            it { expect(subject).to be false }
          end

          context 'when the video is too short' do
            let(:path) { media_folder.join 'short video.mp4' }
            it { expect(subject).to be false }
          end

          context 'when the media elements folder size exceeds the maximum value allowed' do
            let(:path)                                    { valid_media_path }
            let(:prev_maximum_media_elements_folder_size) { Media::Uploader::MAXIMUM_MEDIA_ELEMENTS_FOLDER_SIZE }
            before do
              prev_maximum_media_elements_folder_size
              silence_warnings { Media::Uploader.const_set :MAXIMUM_MEDIA_ELEMENTS_FOLDER_SIZE, Media::Uploader.media_elements_folder_size-1 }
            end
            it { expect(subject).to be false }
            after { silence_warnings { Media::Uploader.const_set :MAXIMUM_MEDIA_ELEMENTS_FOLDER_SIZE, prev_maximum_media_elements_folder_size } }
          end
        end

        context 'when media type is a File' do
          let(:media) { File.open(path) }

          include_examples 'when media is a not converted video'
        end

        context 'when media type is a ActionDispatch::Http::UploadedFile' do
          let(:media) { ActionDispatch::Http::UploadedFile.new(filename: File.basename(path), tempfile: File.open(path)) }

          include_examples 'when media is a not converted video'
        end

        context 'when media type is blank' do
          let(:media) { nil }
          it { expect(subject).to be false }
        end

        context 'when media type is invalid' do
          let(:media) { %w(invalid media type) }
          it { expect(subject).to be false }
        end

        context 'when media type is a String' do
          context 'when the model is not marked for renaming' do
            context 'when media is valid and not changed' do
              subject do 
                ::Video.new(title: 'title', description: 'description', tags: 'a,b,c,d,e', media: media_hash, user: User.admin) do |v| 
                  v.save!
                  v.reload
                end.valid?
              end
              it { expect(subject).to be true }
            end

            context 'when is blank' do
              let(:media) { '' }
              it { expect(subject).to be false }
            end

            context 'when the processed filename is blank' do
              let(:media) { '%' }
              it { expect(subject).to be false }
            end
          end

          context 'when the model is marked for media renaming' do
            subject do 
              ::Video.new(title: 'title', description: 'description', tags: 'a,b,c,d,e', media: media, user: User.admin) do |v| 
                v.rename_media = true
              end.valid?
            end

            context 'when is blank' do
              let(:media) { '' }
              it { expect(subject).to be false }
            end

            context 'when the name is valid' do
              let(:media) { 'asd' }
              it { expect(subject).to be true }
            end
          end
        end

        context 'when media is a Hash' do
          context 'when media is valid' do
            let(:media) { media_hash }
            it { expect(subject).to be true }
          end

          context 'when filename is blank' do
            let(:media) { media_hash.merge(filename: nil) }
            it { expect(subject).to be false }
          end

          context 'when mp4 file extension is invalid' do
            let(:media) { media_hash.merge(mp4: media_hash[:webm]) }
            it { expect(subject).to be false }
          end

          context 'when webm file extension is invalid' do
            let(:media) { media_hash.merge(webm: media_hash[:mp4]) }
            it { expect(subject).to be false }
          end

          context 'when mp4 file is not a valid video' do
            let(:media) { media_hash.merge(mp4: media_folder.join('invalid video.mp4').to_s) }
            it { expect(subject).to be false }
          end

          context 'when webm file is not a valid video' do
            let(:media) { media_hash.merge(webm: media_folder.join('invalid video.webm').to_s) }
            it { expect(subject).to be false }
          end

          context 'when videos are too short' do
            let(:media) { media_hash.merge(mp4: media_folder.join('short video.mp4').to_s, webm: media_folder.join('short video.webm').to_s) }
            it { expect(subject).to be false }
          end

          context 'when videos have different durations' do
            let(:media) { media_hash.merge(mp4: media_folder.join('concat 1.mp4').to_s, webm: media_folder.join('concat 2.webm').to_s) }
            it { expect(subject).to be false }
          end
        end
      end
    end
  end
end