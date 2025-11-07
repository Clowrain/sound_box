import { useState, useEffect, useRef } from "react";
import { SoundCard, Sound } from "./SoundCard";
import { PlayerControl } from "./PlayerControl";
import { PlayingSoundsFloat } from "./PlayingSoundsFloat";
import { ArrowLeft } from "lucide-react";
import { Button } from "./ui/button";

// Mock audio context for demonstration
const createMockAudio = () => {
  const audio = new Audio();
  audio.loop = true;
  // In a real app, you would set audio.src to actual sound files
  return audio;
};

const SOUNDS: Sound[] = [
  {
    id: "rain",
    name: "滑滑细雨",
    icon: "🌧️",
  },
  {
    id: "fire",
    name: "篝火冉冉",
    icon: "🔥",
  },
  {
    id: "thunder",
    name: "夏雷阵阵",
    icon: "⚡",
  },
  {
    id: "cat",
    name: "猫儿梦呓",
    icon: "😺",
  },
  {
    id: "whale",
    name: "鲸鱼",
    icon: "🐋",
  },
  {
    id: "ocean",
    name: "沧海桑田",
    icon: "🌊",
  },
  {
    id: "donkey",
    name: "驴声",
    icon: "🐴",
  },
  {
    id: "forest",
    name: "静谧森林",
    icon: "🌲",
  },
  {
    id: "wood",
    name: "木鱼",
    icon: "🪵",
  },
];

interface SoundState {
  volume: number;
  isPlaying: boolean;
}

type SoundsState = {
  [key: string]: SoundState;
};

interface SoundsPageProps {
  onBack: () => void;
}

export function SoundsPage({ onBack }: SoundsPageProps) {
  const [soundsState, setSoundsState] = useState<SoundsState>({});
  const [timer, setTimer] = useState<number | null>(null);
  const [remainingTime, setRemainingTime] = useState<number | null>(null);
  const audioRefs = useRef<{ [key: string]: HTMLAudioElement }>({});
  const timerRef = useRef<NodeJS.Timeout | null>(null);

  // Initialize audio elements
  useEffect(() => {
    SOUNDS.forEach((sound) => {
      if (!audioRefs.current[sound.id]) {
        audioRefs.current[sound.id] = createMockAudio();
      }
    });

    return () => {
      // Cleanup audio on unmount
      Object.values(audioRefs.current).forEach((audio) => {
        audio.pause();
      });
    };
  }, []);

  // Handle timer
  useEffect(() => {
    if (timer !== null) {
      setRemainingTime(timer * 60); // Convert to seconds
      
      const interval = setInterval(() => {
        setRemainingTime((prev) => {
          if (prev === null || prev <= 1) {
            handlePauseAll();
            setTimer(null);
            if (timerRef.current) {
              clearInterval(timerRef.current);
            }
            return null;
          }
          return prev - 1;
        });
      }, 1000);
      
      timerRef.current = interval;
      
      return () => {
        if (timerRef.current) {
          clearInterval(timerRef.current);
        }
      };
    }
  }, [timer]);

  const handleToggleSound = (soundId: string) => {
    setSoundsState((prev) => {
      const currentState = prev[soundId];
      const newIsPlaying = !currentState?.isPlaying;
      const newVolume = currentState?.volume ?? 50;

      // In a real app, control actual audio here
      const audio = audioRefs.current[soundId];
      if (audio) {
        if (newIsPlaying) {
          audio.volume = newVolume / 100;
          audio.play().catch(() => {
            // Handle autoplay restrictions
          });
        } else {
          audio.pause();
        }
      }

      return {
        ...prev,
        [soundId]: {
          volume: newVolume,
          isPlaying: newIsPlaying,
        },
      };
    });
  };

  const handleVolumeChange = (soundId: string, volume: number) => {
    setSoundsState((prev) => ({
      ...prev,
      [soundId]: {
        ...prev[soundId],
        volume,
      },
    }));

    // Update actual audio volume
    const audio = audioRefs.current[soundId];
    if (audio) {
      audio.volume = volume / 100;
    }
  };

  const handlePlayAll = () => {
    setSoundsState((prev) => {
      const newState = { ...prev };
      Object.keys(newState).forEach((soundId) => {
        if (newState[soundId]) {
          newState[soundId].isPlaying = true;
          const audio = audioRefs.current[soundId];
          if (audio) {
            audio.volume = newState[soundId].volume / 100;
            audio.play().catch(() => {});
          }
        }
      });
      return newState;
    });
  };

  const handlePauseAll = () => {
    setSoundsState((prev) => {
      const newState = { ...prev };
      Object.keys(newState).forEach((soundId) => {
        if (newState[soundId]) {
          newState[soundId].isPlaying = false;
          const audio = audioRefs.current[soundId];
          if (audio) {
            audio.pause();
          }
        }
      });
      return newState;
    });
  };

  const handleSetTimer = (minutes: number) => {
    setTimer(minutes);
  };

  const handleCancelTimer = () => {
    setTimer(null);
    setRemainingTime(null);
    if (timerRef.current) {
      clearInterval(timerRef.current);
    }
  };

  const hasActiveSounds = Object.values(soundsState).some((state) => state.isPlaying);
  const isAnyPlaying = Object.values(soundsState).some((state) => state.isPlaying);
  
  const playingSounds = SOUNDS.filter(sound => soundsState[sound.id]?.isPlaying);

  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-900 via-purple-900 to-slate-900 text-white">
      {/* Header */}
      <div className="sticky top-0 z-10 bg-black/20 backdrop-blur-md border-b border-white/10">
        <div className="max-w-md mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Button
              onClick={onBack}
              variant="ghost"
              size="icon"
              className="rounded-full hover:bg-white/10"
            >
              <ArrowLeft className="w-5 h-5" />
            </Button>
            <div>
              <h1 className="text-lg">音效设置</h1>
              <p className="text-xs text-white/60">选择你喜欢的音效</p>
            </div>
          </div>
        </div>
      </div>
      
      {/* Playing Sounds Float */}
      <PlayingSoundsFloat 
        playingSounds={playingSounds}
        onRemoveSound={handleToggleSound}
      />

      {/* Content */}
      <div className="max-w-md mx-auto px-4 py-6 pb-32">
        <div className="flex flex-col gap-3">
          {SOUNDS.map((sound) => (
            <SoundCard
              key={sound.id}
              sound={sound}
              volume={soundsState[sound.id]?.volume ?? 50}
              isPlaying={soundsState[sound.id]?.isPlaying ?? false}
              onVolumeChange={(volume) => handleVolumeChange(sound.id, volume)}
              onToggle={() => handleToggleSound(sound.id)}
            />
          ))}
        </div>

        {/* Tips */}
        <div className="mt-8 p-4 bg-white/5 backdrop-blur-sm rounded-xl border border-white/10">
          <p className="text-sm text-white/70 text-center">
            💡 提示：点击音效开始播放，可以混合多个音效
          </p>
        </div>
      </div>

      {/* Player Control */}
      <PlayerControl
        hasActiveSounds={hasActiveSounds}
        isAnyPlaying={isAnyPlaying}
        onPlayAll={handlePlayAll}
        onPauseAll={handlePauseAll}
        onSetTimer={handleSetTimer}
        activeTimer={timer}
        onCancelTimer={handleCancelTimer}
        remainingTime={remainingTime}
      />
    </div>
  );
}
