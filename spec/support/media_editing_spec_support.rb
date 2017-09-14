require 'media'

module MediaEditingSpecSupport
  SAMPLES_FOLDER = Pathname.new File.expand_path('../samples', __FILE__)

  VIDEO_FORMATS = [:mp4, :webm]
  AUDIO_FORMATS = [:m4a, :ogg]

  INVALID_VIDEO             = SAMPLES_FOLDER.join('invalid video.flv').to_s
  VALID_VIDEO               = SAMPLES_FOLDER.join('valid video.flv').to_s
  VALID_VIDEO_WITH_ODD_SIZE = SAMPLES_FOLDER.join('valid video with odd size.webm').to_s
  VALID_AUDIO               = SAMPLES_FOLDER.join('valid audio.m4a').to_s
  INVALID_AUDIO             = SAMPLES_FOLDER.join('invalid audio.m4a').to_s
  VALID_JPG                 = SAMPLES_FOLDER.join('valid image.jpg').to_s
  VALID_PNG                 = SAMPLES_FOLDER.join('valid image.png').to_s

  FILENAME_RE = ->(prefix, postfix = nil) do
    /\A#{Regexp.quote prefix.to_s}_[\w\-]{22}#{Regexp.quote postfix.to_s}\z/
  end

  CONVERTED_VIDEO_HASH      = { mp4: SAMPLES_FOLDER.join('con verted.mp4').to_s,      webm: SAMPLES_FOLDER.join('con verted.webm').to_s,    filename: 'con verted' }
  CONVERTED_AUDIO_HASH      = { m4a: SAMPLES_FOLDER.join('con verted.m4a').to_s,      ogg: SAMPLES_FOLDER.join('con verted.ogg').to_s,      filename: 'con verted' }
  CONVERTED_AUDIO_HASH_LONG = { m4a: SAMPLES_FOLDER.join('con verted long.m4a').to_s, ogg: SAMPLES_FOLDER.join('con verted long.ogg').to_s, filename: 'con verted long' }
  
  CROP_VIDEOS = CONVERTED_VIDEO_HASH.select{ |k| VIDEO_FORMATS.include? k }
  CROP_AUDIOS = CONVERTED_AUDIO_HASH.select{ |k| AUDIO_FORMATS.include? k }
  
  CONCAT_VIDEOS = {
                    videos_with_some_audio_streams: {
                      videos: ['concat 1', 'concat 2'].map{ |i| Hash[ VIDEO_FORMATS.map{ |f| [f, SAMPLES_FOLDER.join("#{i}.#{f}").to_s] } ] } * 2,
                      output_infos: {
                        mp4:  {:duration=>96.36, :streams=>{:video=>[{:codec=>"h264", :width=>960, :height=>540, :bitrate=>865}], :audio=>[{:codec=>"aac", :bitrate=>144}]}},
                        webm: {:duration=>96.34, :streams=>{:video=>[{:codec=>"vp8", :width=>960, :height=>540, :bitrate=>nil}], :audio=>[{:codec=>"vorbis", :bitrate=>nil}]}}
                      }
                    },
                    videos_without_audio_streams:   {
                      videos: ['concat 1'].map{ |i| Hash[ VIDEO_FORMATS.map{ |f| [f, SAMPLES_FOLDER.join("#{i}.#{f}").to_s] } ] } * 2,
                      output_infos: {
                        mp4:  {:duration=>20.0, :streams=>{:video=>[{:codec=>"h264", :width=>960, :height=>540, :bitrate=>56}], :audio=>[]}},
                        webm: {:duration=>20.0, :streams=>{:video=>[{:codec=>"vp8", :width=>960, :height=>540, :bitrate=>nil}], :audio=>[]}}
                      }
                    }
                  }

  REPLACE_AUDIO_VIDEOS = { 
                           videos_with_some_audio_streams: {
                             video_inputs: Hash[ VIDEO_FORMATS.map{ |f| [f, SAMPLES_FOLDER.join("con verted.#{f}").to_s] } ],
                             audio_inputs: Hash[ AUDIO_FORMATS.map{ |f| [f, SAMPLES_FOLDER.join("valid audio 2.#{f}").to_s] } ]
                           },
                           videos_without_audio_streams:   { 
                             video_inputs: Hash[ VIDEO_FORMATS.map{ |f| [f, SAMPLES_FOLDER.join("converted no audio.#{f}").to_s] } ],
                             audio_inputs: Hash[ AUDIO_FORMATS.map{ |f| [f, SAMPLES_FOLDER.join("valid audio 2.#{f}").to_s] } ]
                           }
                         }

  TRANSITION_VIDEOS = {
    start_inputs: Hash[ VIDEO_FORMATS.map{ |f| [f, SAMPLES_FOLDER.join("con verted.#{f}").to_s] } ],
    end_inputs:   Hash[ VIDEO_FORMATS.map{ |f| [f, SAMPLES_FOLDER.join("converted no audio.#{f}").to_s] } ]
  }

  CONCAT_AUDIOS = {
                    audios: ['concat 1', 'concat 2'].map{ |i| Hash[ AUDIO_FORMATS.map{ |f| [f, SAMPLES_FOLDER.join("#{i}.#{f}").to_s] } ] } * 2,
                    output_infos: {
                      m4a:  {:duration=>136.51, :streams=>{:audio=>[{:codec=>"aac", :bitrate=>180}]}},
                      ogg: {:duration=>136.3, :streams=>{:audio=>[{:codec=>"vorbis", :bitrate=>112}]}}
                    }
                  }

  VIDEO_COMPOSING = { without_audio_track: 
                      { 
                        mp4: {:streams=>{:video=>[{:codec=>"h264", :width=>960, :height=>540, :bitrate=>819}], :audio=>[{:codec=>"aac", :bitrate=>63}]}},
                        webm: {:streams=>{:video=>[{:codec=>"vp8", :width=>960, :height=>540, :bitrate=>nil}], :audio=>[{:codec=>"vorbis", :bitrate=>nil}]}}
                      },
                      with_audio_track:
                      { 
                        mp4: {:streams=>{:video=>[{:codec=>"h264", :width=>960, :height=>540, :bitrate=>819}], :audio=>[{:codec=>"aac", :bitrate=>149}]}},
                        webm: {:streams=>{:video=>[{:codec=>"vp8", :width=>960, :height=>540, :bitrate=>nil}], :audio=>[{:codec=>"vorbis", :bitrate=>nil}]}}
                      }
                    }
  AUDIO_COMPOSING = { 
                      m4a: {:duration=>60, :streams=>{:video=>[], :audio=>[{:codec=>"aac", :bitrate=>180}]}}, 
                      ogg: {:duration=>60, :streams=>{:video=>[], :audio=>[{:codec=>"vorbis", :bitrate=>112}]}} 
                    }

  AVCONV_SH_VARS         = {}
  AVCONV_PRE_COMMAND     = 'avconv -loglevel debug -benchmark -y -timelimit 86400'
  AVCONV_SUBEXEC_OPTIONS = { sh_vars: AVCONV_SH_VARS, timeout: 86410 }
  VBITRATE               = { mp4: '', webm: ' -b:v 2M' }

  AVPROBE_PRE_COMMAND     = 'avprobe'
  AVPROBE_SH_VARS         = AVCONV_SH_VARS
  AVPROBE_SUBEXEC_SH_VARS = {"LANG"=>"C"}
  AVPROBE_SUBEXEC_TIMEOUT = 10
  AVPROBE_SUBEXEC_OPTIONS = { sh_vars: AVPROBE_SH_VARS, timeout: AVPROBE_SUBEXEC_TIMEOUT }

  IMAGEMAGICK_CONVERT_PRE_COMMAND = 'convert'
end

MESS = MediaEditingSpecSupport