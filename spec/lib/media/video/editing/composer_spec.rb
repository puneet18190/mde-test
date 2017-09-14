require 'spec_helper'

module Media
  module Video
    module Editing
      describe Composer, slow: true do
        self.use_transactional_fixtures = false

        def user
          @user ||= User.admin
        end

        def video
          @video ||= ::Video.create!(title: 'test', description: 'test', tags: 'a,b,c,d') do |v|
            v.user  = user
            v.media = MESS::CONVERTED_VIDEO_HASH
          end
        end

        def image
          @image ||= ::Image.create!(title: 'test', description: 'test', tags: 'a,b,c,d') do |v|
            v.user  = user
            v.media = File.open(MESS::VALID_JPG)
          end
        end

        def audio
          @audio ||= ::Audio.create!(title: 'test', description: 'test', tags: 'a,b,c,d') do |v|
            v.user  = user
            v.media = MESS::CONVERTED_AUDIO_HASH
          end
        end

        def audio_long
          @audio_long ||= ::Audio.create!(title: 'test', description: 'test', tags: 'a,b,c,d') do |v|
            v.user  = user
            v.media = MESS::CONVERTED_AUDIO_HASH_LONG
          end
        end

        def initial_video_attributes
          @initial_video_attributes ||= { title: 'new title', description: 'new description', tags: 'e,f,g,h' }
        end

        def info(format)
          @info ||= {}
          @info[format] ||= Info.new(initial_video.media.path(format))
        end

        describe '#run' do
          def params
            @params ||= { audio_track: audio_track,
                          components: [
                            { type:  described_class::parent::Parameters::VIDEO_COMPONENT,
                              video: video.id            ,
                              from:  5                   ,
                              to:    video.min_duration },
                            { type:             described_class::parent::Parameters::TEXT_COMPONENT,
                              content:          'title'  ,
                              duration:         5        ,
                              background_color: 'red'    ,
                              color:            'white' },
                            { type:             described_class::parent::Parameters::IMAGE_COMPONENT,
                              image:            image.id ,
                              duration:         10       }
                          ] * 2
                        }
          end

          def duration
            @duration ||= params[:components].map do |c|
                            case c[:type]
                            when described_class::parent::Parameters::VIDEO_COMPONENT
                              c[:to] - c[:from]
                            when described_class::parent::Parameters::TEXT_COMPONENT, described_class::parent::Parameters::IMAGE_COMPONENT
                              c[:duration]
                            end
                          end.sum + (params[:components].size-1)
          end
          
          def expected_infos(type, format)
            MESS::VIDEO_COMPOSING[type][format].merge(duration: duration)
          end

          def params_with_initial_video
            @params_with_initial_video ||= params.merge(initial_video: { id: initial_video.id })
          end

          context 'without an uploaded initial video' do

            def initial_video
              @initial_video ||= ::Video.find ::Video.create!(initial_video_attributes) { |r|
                r.user      = user
                r.composing = true
              }.id
            end
            
            context 'without audio track' do
              def audio_track
                nil
              end

              def user_notifications_count
                @user_notifications_count ||= user.notifications.count
              end

              before(:all) do
                user.video_editor_cache!(params_with_initial_video)
                user_notifications_count
                described_class.new(params_with_initial_video).run
                initial_video.reload
              end

              MESS::VIDEO_FORMATS.each do |format|
                context "with #{format} format", format: format do
              
                  let!(:format) { format }

                  it 'creates the correct video' do
                    expect(info(format).similar_to?(expected_infos(:without_audio_track, format), true)).to be true
                  end
                end
              end

              it 'sends a notification to the user' do
                expect(initial_video.user.notifications.count).to eq user_notifications_count+1
              end

              it 'deletes the video editor cache' do
                expect(initial_video.user.video_editor_cache).to be_nil
              end
            end
            
            context 'with audio track' do
              def audio_track
                nil
              end

              def user_notifications_count
                @user_notifications_count ||= user.notifications.count
              end

              before(:all) do
                user.video_editor_cache!(params_with_initial_video)
                user_notifications_count
                described_class.new(params_with_initial_video).run
                initial_video.reload
              end

              MESS::VIDEO_FORMATS.each do |format|
                context "with #{format} format", format: format do
              
                  let(:format) { format }

                  it 'creates the correct video' do
                    expect(info(format).similar_to?(expected_infos(:with_audio_track, format), true)).to be true
                  end
                end
              end

              it 'sends a notification to the user' do
                expect(initial_video.user.notifications.count).to eq user_notifications_count+1
              end

              it 'deletes the video editor cache' do
                expect(initial_video.user.video_editor_cache).to be_nil
              end
            end

            context 'with an audio track longer than the video generated' do
              def audio_track
                @audio_track ||= audio_long.id
              end

              def user_notifications_count
                @user_notifications_count ||= user.notifications.count
              end

              before(:all) do
                user.video_editor_cache!(params_with_initial_video)
                user_notifications_count
                described_class.new(params_with_initial_video).run
                initial_video.reload
              end

              MESS::VIDEO_FORMATS.each do |format|
                context "with #{format} format", format: format do
              
                  let(:format) { format }

                  it 'creates the correct video' do
                    expect(info(format).similar_to?(expected_infos(:with_audio_track, format), true)).to be true
                  end
                end
              end

              it 'sends a notification to the user' do
                expect(initial_video.user.notifications.count).to eq user_notifications_count+1
              end

              it 'deletes the video editor cache' do
                expect(initial_video.user.video_editor_cache).to be_nil
              end
            end

          end

          context 'with an uploaded initial video' do

            def initial_video
              @initial_video ||= ::Video.find ::Video.create!(initial_video_attributes) { |v|
                v.user                = user
                v.media               = MESS::CONVERTED_VIDEO_HASH
                v.metadata.old_fields = { title: 'old title', description: 'old description', tags: 'a,b,c,d' }
              }.id
            end

            def old_files
              @old_files ||= initial_video.media.paths.values.dup
            end

            context 'without audio track' do
              def audio_track
                nil
              end

              def user_notifications_count
                @user_notifications_count ||= user.notifications.count
              end

              before(:all) do
                old_files
                user.video_editor_cache!(params_with_initial_video)
                user_notifications_count
                described_class.new(params_with_initial_video).run
                initial_video.reload
              end

              MESS::VIDEO_FORMATS.each do |format|
                context "with #{format} format", format: format do
              
                  let(:format) { format }

                  it 'creates the correct video' do
                    expect(info(format).similar_to?(expected_infos(:without_audio_track, format), true)).to be true
                  end
                end
              end

              it 'deletes the video old_fields metadata' do
                expect(initial_video.metadata.old_fields).to be_nil
              end

              it 'sends a notification to the user' do
                expect(initial_video.user.notifications.count).to eq user_notifications_count+1
              end

              it 'deletes the video editor cache' do
                expect(initial_video.user.video_editor_cache).to be_nil
              end

              it 'deletes the old files' do
                old_files.each { |f| expect(File.exists?(f)).to be false }
              end
            end

            context 'with audio track' do
              def audio_track
                @audio_track ||= audio
              end

              def user_notifications_count
                @user_notifications_count ||= user.notifications.count
              end

              before(:all) do
                old_files
                user.video_editor_cache!(params_with_initial_video)
                user_notifications_count
                described_class.new(params_with_initial_video).run
                initial_video.reload
              end

              MESS::VIDEO_FORMATS.each do |format|
                context "with #{format} format", format: format do
              
                  let(:format) { format }

                  it 'creates the correct video' do
                    expect(info(format).similar_to?(expected_infos(:with_audio_track, format), true)).to be true
                  end
                end
              end

              it 'deletes the video old_fields metadata' do
                expect(initial_video.metadata.old_fields).to be_nil
              end

              it 'sends a notification to the user' do
                expect(initial_video.user.notifications.count).to eq user_notifications_count+1
              end

              it 'deletes the video editor cache' do
                expect(initial_video.user.video_editor_cache).to be_nil
              end

              it 'deletes the old files' do
                old_files.each { |f| expect(File.exists?(f)).to be false }
              end
            end
          end
        end

      end
    end
  end
end