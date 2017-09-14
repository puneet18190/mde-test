require 'spec_helper'

module Media
  module Video
    module Editing
      describe TextToVideo do

        def text
          @text ||= Tempfile.open(Rails.application.config.tempfiles_prefix.call) do |f|
            f.write("Test\ntest")
            f
          end
        end
        def dir
          @dir ||= Dir.mktmpdir('desy_spec')
        end
        let(:output_without_extension) { Rails.root.join('tmp/output').to_s }
        let(:options)                  { { color: '#41A62A', background_color: '#373737' } }
        let(:duration)                 { 5 }

        it 'works' do
          expect{ described_class.new(text, output_without_extension, duration, options).run }.to_not raise_error
        end

        after(:all) do
          FileUtils.remove_entry_secure dir if Dir.exist? dir
        end
      end
    end
  end
end