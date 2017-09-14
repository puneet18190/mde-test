require 'spec_helper'

module Media
  module Audio
    module Editing
      describe Composer do
        self.use_transactional_fixtures = false

        def pools
          @pools ||= Rails.configuration.database_configuration[Rails.env]['pool']
        end

        def user
          @user ||= User.admin
        end
        
        def components
          @components ||= (pools+5).times.map do
            ::Audio.create!(title: 'test', description: 'test', tags: 'a,b,c,d') do |v|
              v.user  = user
              v.media = MESS::CONVERTED_AUDIO_HASH
            end
          end
        end

        def initial_audio_attributes
          @initial_audio_attributes ||= { title: 'new title', description: 'new description', tags: 'e,f,g,h' }
        end

        def info(format)
          @info ||= {}
          @info[format] ||= Info.new(initial_audio.media.path(format))
        end

        describe '#run' do
          def params
            @params ||= { components: components.map do |record|
                          { audio: record.id,
                            from:  10       ,
                            to:    20      }
                          end
                        }
          end
          let!(:duration) do
            params[:components].map do |c|
              c[:to] - c[:from]
            end.sum
          end
          def expected_infos(format)
            MESS::AUDIO_COMPOSING[format].merge(duration: duration)
          end

          def params_with_initial_audio
            @params_with_initial_audio ||= params.merge(initial_audio: { id: initial_audio.id })
          end

          context 'without an uploaded initial audio' do

            def initial_audio
              @initial_audio ||= ::Audio.create!(initial_audio_attributes) do |r|
                r.user      = user
                r.composing = true
              end
            end
            
            def user_notifications_count
              @user_notifications_count ||= user.notifications.count
            end

            before(:all) do
              user.audio_editor_cache!(params_with_initial_audio)
              user_notifications_count
              described_class.new(params_with_initial_audio).run
              initial_audio.reload
            end

            MESS::AUDIO_FORMATS.each do |format|
              context "with #{format} format", format: format do
            
                let!(:format) { format }

                it 'creates the correct audio' do
                  expect(info(format).similar_to?(expected_infos(format), true)).to be true
                end
              end
            end

            it 'sends a notification to the user' do
              expect(initial_audio.user.notifications.count).to eq user_notifications_count+1
            end

            it 'deletes the audio editor cache' do
              expect(initial_audio.user.audio_editor_cache).to be_nil
            end

          end

          context 'with an uploaded initial audio' do
            def initial_audio
              @initial_audio ||= ::Audio.find ::Audio.create!(initial_audio_attributes) { |v|
                v.user                = user
                v.media               = MESS::CONVERTED_AUDIO_HASH
                v.metadata.old_fields = { title: 'old title', description: 'old description', tags: 'a,b,c,d' }
              }
            end

            def user_notifications_count
              @user_notifications_count ||= user.notifications.count
            end
            
            def old_files
              @old_files ||= initial_audio.media.paths.values.dup
            end

            before(:all) do
              old_files
              user.audio_editor_cache!(params_with_initial_audio)
              user_notifications_count
              described_class.new(params_with_initial_audio).run
              initial_audio.reload
            end

            MESS::AUDIO_FORMATS.each do |format|
              context "with #{format} format", format: format do
            
                let(:format) { format }

                it 'creates the correct audio' do
                  expect(info(format).similar_to?(expected_infos(format), true)).to be true
                end
              end
            end

            it 'deletes the audio old_fields metadata' do
              expect(initial_audio.metadata.old_fields).to be_nil
            end

            it 'sends a notification to the user' do
              expect(initial_audio.user.notifications.count).to eq user_notifications_count+1
            end

            it 'deletes the audio editor cache' do
              expect(initial_audio.user.audio_editor_cache).to be_nil
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