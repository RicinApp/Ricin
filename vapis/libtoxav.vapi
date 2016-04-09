[CCode (cheader_filename="toxav/toxav.h", cprefix="ToxAV", lower_case_cprefix="toxav_")]
namespace ToxAV {
    namespace Version {
        /**
         * The major version number. Incremented when the API or ABI changes in an
         * incompatible way.
         */
        public const uint32 MAJOR;

        /**
         * The minor version number. Incremented when functionality is added without
         * breaking the API or ABI. Set to 0 when the major version number is
         * incremented.
         */
        public const uint32 MINOR;

        /**
         * The patch or revision number. Incremented when bugfixes are applied without
         * changing any functionality or API or ABI.
         */
        public const uint32 PATCH;

        /**
         * A macro to check at preprocessing time whether the client code is compatible
         * with the installed version of ToxAV
         */
        [CCode (cname="TOXAV_VERSION_IS_API_COMPATIBLE")]
        public static bool is_api_compatible (uint32 major, uint32 minor, uint32 patch);

        /**
         * A convenience macro to call toxav_version_is_compatible with the currently
         * compiling API version.
         */
        [CCode (cname="TOXAV_VERSION_IS_ABI_COMPATIBLE")]
        public static bool is_abi_compatible ();

        /**
         * A macro to make compilation fail if the client code is not compatible with
         * the installed version of
         */
        [CCode (cname="TOXAV_VERSION_REQUIRE")]
        public static char require_version (uint32 major, uint32 minor, uint32 patch);

        /**
         * Return the major version number of the library. Can be used to display the
         * Tox library version or to check whether the client is compatible with the
         * dynamically linked version of ToxAV
         */
        [CCode (cname="toxav_version_major")]
        public static uint32 lib_major ();

        /**
         * Return the minor version number of the library.
         */
        [CCode (cname="toxav_version_minor")]
        public static uint32 lib_minor ();

        /**
         * Return the patch number of the library.
         */
        [CCode (cname="toxav_version_patch")]
        public static uint32 lib_patch ();

        /**
         * Return whether the compiled library version is compatible with the passed
         * version numbers.
         */
        [CCode (cname="toxav_version_is_compatible")]
        public static bool is_compatible (uint32 major, uint32 minor, uint32 patch);
    }

    /*******************************************************************************
     *
     * :: Global enumerations
     *
     ******************************************************************************/

    [CCode (cname="TOXAV_FRIEND_CALL_STATE", cprefix="TOXAV_FRIEND_CALL_STATE_", has_type_id=false)]
    public enum FriendCallState {
        /**
        * Set by the AV core if an error occurred on the remote end or if friend
        * timed out. This is the final state after which no more state
        * transitions can occur for the call. This call state will never be triggered
        * in combination with other call states.
        */
        ERROR,
        /**
         * The call has finished. This is the final state after which no more state
         * transitions can occur for the call. This call state will never be
         * triggered in combination with other call states.
         */
        FINISHED,
        /**
         * The flag that marks that friend is sending audio.
         */
        SENDING_A,
        /**
         * The flag that marks that friend is sending video.
         */
        SENDING_V,
        /**
         * The flag that marks that friend is receiving audio.
         */
        ACCEPTING_A,
        /**
         * The flag that marks that friend is receiving video.
         */
        ACCEPTING_V
    }

    [CCode (cname="TOXAV_CALL_CONTROL", cprefix="TOXAV_CALL_CONTROL_", has_type_id=false)]
    public enum CallControl {
        /**
         * Resume a previously paused call. Only valid if the pause was caused by this
         * client, if not, this control is ignored. Not valid before the call is accepted.
         */
        RESUME,
        /**
         * Put a call on hold. Not valid before the call is accepted.
         */
        PAUSE,
        /**
         * Reject a call if it was not answered, yet. Cancel a call after it was
         * answered.
         */
        CANCEL,
        /**
         * Request that the friend stops sending audio. Regardless of the friend's
         * compliance, this will cause the audio_receive_frame event to stop being
         * triggered on receiving an audio frame from the friend.
         */
        MUTE_AUDIO,
        /**
         * Calling this control will notify client to start sending audio again.
         */
        UNMUTE_AUDIO,
        /**
         * Request that the friend stops sending video. Regardless of the friend's
         * compliance, this will cause the video_receive_frame event to stop being
         * triggered on receiving a video frame from the friend.
         */
        HIDE_VIDEO,
        /**
         * Calling this control will notify client to start sending video again.
         */
        SHOW_VIDEO
    }



    /*******************************************************************************
     *
     * :: Errors enums
     *
     ******************************************************************************/

    [CCode (cname="TOXAV_ERR_NEW", cprefix="TOXAV_ERR_NEW_")]
    public enum ERR_NEW {
        /**
         * The function returned successfully.
         */
        OK,
        /**
         * One of the arguments to the function was NULL when it was not expected.
         */
        NULL,
        /**
         * Memory allocation failure while trying to allocate structures required for
         * the A/V session.
         */
        MALLOC,
        /**
         * Attempted to create a second session for the same Tox instance.
         */
        MULTIPLE
    }

    [CCode (cname="TOXAV_ERR_CALL", cprefix="TOXAV_ERR_CALL_")]
    public enum ERR_CALL {
        /**
         * The function returned successfully.
         */
        OK,
        /**
         * A resource allocation error occurred while trying to create the structures
         * required for the call.
         */
        MALLOC,
        /**
         * Synchronization error occurred.
         */
        SYNC,
        /**
         * The friend number did not designate a valid friend.
         */
        FRIEND_NOT_FOUND,
        /**
         * The friend was valid, but not currently connected.
         */
        FRIEND_NOT_CONNECTED,
        /**
         * Attempted to call a friend while already in an audio or video call with
         * them.
         */
        FRIEND_ALREADY_IN_CALL,
        /**
         * Audio or video bit rate is invalid.
         */
        INVALID_BIT_RATE
    }

    [CCode (cname="TOXAV_ERR_CALL_CONTROL", cprefix="TOXAV_ERR_CALL_CONTROL_")]
    public enum ERR_CALL_CONTROL {
        /**
         * The function returned successfully.
         */
        OK,
        /**
         * Synchronization error occurred.
         */
        SYNC,
        /**
         * The friend_number passed did not designate a valid friend.
         */
        FRIEND_NOT_FOUND,
        /**
         * This client is currently not in a call with the friend. Before the call is
         * answered, only CANCEL is a valid control.
         */
        FRIEND_NOT_IN_CALL,
        /**
         * Happens if user tried to pause an already paused call or if trying to
         * resume a call that is not paused.
         */
        INVALID_TRANSITION
    }

    [CCode (cname="TOXAV_ERR_ANSWER", cprefix="TOXAV_ERR_ANSWER_")]
    public enum ERR_ANSWER {
        /**
         * The function returned successfully.
         */
        TOXAV_ERR_ANSWER_OK,
        /**
         * Synchronization error occurred.
         */
        TOXAV_ERR_ANSWER_SYNC,
        /**
         * Failed to initialize codecs for call session. Note that codec initiation
         * will fail if there is no receive callback registered for either audio or
         * video.
         */
        TOXAV_ERR_ANSWER_CODEC_INITIALIZATION,
        /**
         * The friend number did not designate a valid friend.
         */
        TOXAV_ERR_ANSWER_FRIEND_NOT_FOUND,
        /**
         * The friend was valid, but they are not currently trying to initiate a call.
         * This is also returned if this client is already in a call with the friend.
         */
        TOXAV_ERR_ANSWER_FRIEND_NOT_CALLING,
        /**
         * Audio or video bit rate is invalid.
         */
        TOXAV_ERR_ANSWER_INVALID_BIT_RATE
    }

    [CCode (cname="TOXAV_ERR_SEND_FRAME", cprefix="TOXAV_ERR_SEND_FRAME_")]
    public enum ERR_SEND_FRAME {
        /**
         * The function returned successfully.
         */
        TOXAV_ERR_SEND_FRAME_OK,
        /**
         * In case of video, one of Y, U, or V was NULL. In case of audio, the samples
         * data pointer was NULL.
         */
        TOXAV_ERR_SEND_FRAME_NULL,
        /**
         * The friend_number passed did not designate a valid friend.
         */
        TOXAV_ERR_SEND_FRAME_FRIEND_NOT_FOUND,
        /**
         * This client is currently not in a call with the friend.
         */
        TOXAV_ERR_SEND_FRAME_FRIEND_NOT_IN_CALL,
        /**
         * One of the frame parameters was invalid. E.g. the resolution may be too
         * small or too large, or the audio sampling rate may be unsupported.
         */
        TOXAV_ERR_SEND_FRAME_INVALID,
        /**
         * Either friend turned off audio or video receiving or we turned off sending
         * for the said payload.
         */
        TOXAV_ERR_SEND_FRAME_PAYLOAD_TYPE_DISABLED,
        /**
         * Failed to push frame through rtp interface.
         */
        TOXAV_ERR_SEND_FRAME_RTP_FAILED
    }

    [CCode (cname="TOXAV_ERR_BIT_RATE_SET", cprefix="TOXAV_ERR_BIT_RATE_SET_")]
    public enum ERR_BIT_RATE_SET {
        /**
         * The function returned successfully.
         */
        OK,
        /**
         * Synchronization error occurred.
         */
        SYNC,
        /**
         * The audio bit rate passed was not one of the supported values.
         */
        INVALID_AUDIO_BIT_RATE,
        /**
         * The video bit rate passed was not one of the supported values.
         */
        INVALID_VIDEO_BIT_RATE,
        /**
         * The friend_number passed did not designate a valid friend.
         */
        FRIEND_NOT_FOUND,
        /**
         * This client is currently not in a call with the friend.
         */
        FRIEND_NOT_IN_CALL
    }

    [CCode (cname="ToxAV", free_function="toxav_kill", cprefix="toxav_", has_type_id=false)]
    [Compact]
    public class ToxAV {
        /**
         * Start new A/V session. There can only be only one session per Tox instance.
         */
        public ToxAV (ToxCore.Tox tox, out ERR_NEW? error = null);

        /**
         * Returns the Tox instance the A/V object was created for.
         */
        public ToxCore.Tox get_tox (ToxAV tox_av);

        /**
         * Returns the interval in milliseconds when the next toxav_iterate call should
         * be. If no call is active at the moment, this function returns 200.
         */
        public uint32 iteration_interval ();

        /**
         * Main loop for the session. This function needs to be called in intervals of
         * toxav_iteration_interval() milliseconds. It is best called in the separate
         * thread from tox_iterate.
         */
        public void iterate ();

        /**
         * Call a friend. This will start ringing the friend.
         *
         * It is the client's responsibility to stop ringing after a certain timeout,
         * if such behaviour is desired. If the client does not stop ringing, the
         * library will not stop until the friend is disconnected. Audio and video
         * receiving are both enabled by default.
         *
         * @param friend_number The friend number of the friend that should be called.
         * @param audio_bit_rate Audio bit rate in Kb/sec. Set this to 0 to disable
         * audio sending.
         * @param video_bit_rate Video bit rate in Kb/sec. Set this to 0 to disable
         * video sending.
         */
        public bool call (uint32 friend_number, uint32 audio_bit_rate, uint32 video_bit_rate, out ERR_CALL error);

        /**
         * The function type for the call callback.
         *
         * @param friend_number The friend number from which the call is incoming.
         * @param audio_enabled True if friend is sending audio.
         * @param video_enabled True if friend is sending video.
         */
        [CCode (cname="toxav_call_cb", has_type_id=false)]
        public delegate void CallFunc (ToxAV self, uint32 friend_number, bool audio_enabled, bool video_enabled);

        /**
         * Set the callback for the `call` event. Pass NULL to unset.
         *
         */
        public void callback_call (CallFunc callback);

        /**
         * Accept an incoming call.
         *
         * If answering fails for any reason, the call will still be pending and it is
         * possible to try and answer it later. Audio and video receiving are both
         * enabled by default.
         *
         * @param friend_number The friend number of the friend that is calling.
         * @param audio_bit_rate Audio bit rate in Kb/sec. Set this to 0 to disable
         * audio sending.
         * @param video_bit_rate Video bit rate in Kb/sec. Set this to 0 to disable
         * video sending.
         */
        public bool answer (uint32 friend_number, uint32 audio_bit_rate, uint32 video_bit_rate, out ERR_ANSWER error);

        /**
         * The function type for the call_state callback.
         *
         * @param friend_number The friend number for which the call state changed.
         * @param state The bitmask of the new call state which is guaranteed to be
         * different than the previous state. The state is set to 0 when the call is
         * paused. The bitmask represents all the activities currently performed by the
         * friend.
         */
        [CCode (cname="toxav_call_cb", has_type_id=false)]
        public delegate void CallStateFunc (ToxAV self, uint32 friend_number, uint32 state);

        /**
         * Set the callback for the `call_state` event. Pass NULL to unset.
         *
         */
        public void callback_call_state (CallStateFunc callback);

        /**
         * Sends a call control command to a friend.
         *
         * @param friend_number The friend number of the friend this client is in a call
         * with.
         * @param control The control command to send.
         *
         * @return true on success.
         */
        public bool call_control (uint32 friend_number, CallControl control, out ERR_CALL_CONTROL error);

        /**
         * Set the audio bit rate to be used in subsequent audio/video frames.
         *
         * @param friend_number The friend number of the friend for which to set the
         * audio bit rate.
         * @param audio_bit_rate The new audio bit rate in Kb/sec. Set to 0 to disable
         * audio sending. Set to -1 to leave unchanged.
         * @param video_bit_rate The new video bit rate in Kb/sec. Set to 0 to disable
         * video sending. Set to -1 to leave unchanged.
         *
         */
        public bool bit_rate_set (uint32 friend_number, uint32 audio_bit_rate, uint32 video_bit_rate, out ERR_BIT_RATE_SET error);

        /**
         * The function type for the bit_rate_status callback. The event is triggered
         * when the network becomes too saturated for current bit rates at which
         * point core suggests new bit rates.
         *
         * @param friend_number The friend number of the friend for which to set the
         * audio bit rate.
         * @param audio_bit_rate Suggested maximum audio bit rate in Kb/sec.
         * @param video_bit_rate Suggested maximum video bit rate in Kb/sec.
         */
        [CCode (cname="toxav_bit_rate_set_status_cb", has_type_id = false)]
        public delegate void BitRateStatusFunc (uint32 friend_number, uint32 audio_bit_rate, uint32 video_bit_rate);

        /**
         * Set the callback for the `bit_rate_status` event. Pass NULL to unset.
         *
         */
        public void callback_bit_rate_status (BitRateStatusFunc callback);

        /**
         * Send an audio frame to a friend.
         *
         * The expected format of the PCM data is: [s1c1][s1c2][...][s2c1][s2c2][...]...
         * Meaning: sample 1 for channel 1, sample 1 for channel 2, ...
         * For mono audio, this has no meaning, every sample is subsequent. For stereo,
         * this means the expected format is LRLRLR... with samples for left and right
         * alternating.
         *
         * @param friend_number The friend number of the friend to which to send an
         * audio frame.
         * @param pcm An array of audio samples. The size of this array must be
         * sample_count * channels.
         * @param sample_count Number of samples in this frame. Valid numbers here are
         * ((sample rate) * (audio length) / 1000), where audio length can be
         * 2.5, 5, 10, 20, 40 or 60 millseconds.
         * @param channels Number of audio channels. Supported values are 1 and 2.
         * @param sampling_rate Audio sampling rate used in this frame. Valid sampling
         * rates are 8000, 12000, 16000, 24000, or 48000.
         */
        public bool audio_send_frame (uint32 friend_number, [CCode (array_length=false)] int16[] pcm, size_t sample_count, uint8 channels, uint32 sampling_rate, out ERR_SEND_FRAME error);

        /**
         * Send a video frame to a friend.
         *
         * Y - plane should be of size: height * width
         * U - plane should be of size: (height/2) * (width/2)
         * V - plane should be of size: (height/2) * (width/2)
         *
         * @param friend_number The friend number of the friend to which to send a video
         * frame.
         * @param width Width of the frame in pixels.
         * @param height Height of the frame in pixels.
         * @param y Y (Luminance) plane data.
         * @param u U (Chroma) plane data.
         * @param v V (Chroma) plane data.
         */
        public bool video_send_frame (uint32 friend_number, uint16 width, uint16 height, out uint8 y, out uint8 u, out uint8 v, out ERR_SEND_FRAME error);

        /**
         * The function type for the audio_receive_frame callback. The callback can be
         * called multiple times per single iteration depending on the amount of queued
         * frames in the buffer. The received format is the same as in send function.
         *
         * @param friend_number The friend number of the friend who sent an audio frame.
         * @param pcm An array of audio samples (sample_count * channels elements).
         * @param sample_count The number of audio samples per channel in the PCM array.
         * @param channels Number of audio channels.
         * @param sampling_rate Sampling rate used in this frame.
         *
         */
        public delegate void AudioReceiveFrameFunc (ToxAV self, uint32 friend_number, [CCode (array_length=false)] int16[] pcm, size_t sample_count, uint8 channels, uint32 sampling_rate);

        /**
         * Set the callback for the `audio_receive_frame` event. Pass NULL to unset.
         *
         */
        public void callback_audio_receive_frame (AudioReceiveFrameFunc callback);

        /**
         * The function type for the video_receive_frame callback.
         *
         * @param friend_number The friend number of the friend who sent a video frame.
         * @param width Width of the frame in pixels.
         * @param height Height of the frame in pixels.
         * @param y
         * @param u
         * @param v Plane data.
         *          The size of plane data is derived from width and height where
         *          Y = MAX(width, abs(ystride)) * height,
         *          U = MAX(width/2, abs(ustride)) * (height/2) and
         *          V = MAX(width/2, abs(vstride)) * (height/2).
         * @param ystride
         * @param ustride
         * @param vstride Strides data. Strides represent padding for each plane
         *                that may or may not be present. You must handle strides in
         *                your image processing code. Strides are negative if the
         *                image is bottom-up hence why you MUST abs() it when
         *                calculating plane buffer size.
         */
        public delegate void VideoReceiveFrameFunc (ToxAV self, uint32 friend_number, uint16 width, uint16 height, out uint8 y, out uint8 u, out uint8 v, out int32 ystride, out int32 ustride, out int32 vstride);

        /**
         * Set the callback for the `video_receive_frame` event. Pass NULL to unset.
         *
         */
        public void callback_video_receive_frame (VideoReceiveFrameFunc callback);
    }
}
