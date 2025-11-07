import { X } from "lucide-react";
import { Sound } from "./SoundCard";

interface PlayingSoundsFloatProps {
  playingSounds: Sound[];
  onRemoveSound: (soundId: string) => void;
}

export function PlayingSoundsFloat({ playingSounds, onRemoveSound }: PlayingSoundsFloatProps) {
  if (playingSounds.length === 0) return null;

  return (
    <div className="fixed top-24 left-4 right-4 z-20 pointer-events-none">
      <div className="max-w-md mx-auto">
        <div className="flex flex-wrap gap-2 justify-center pointer-events-auto">
          {playingSounds.map((sound) => (
            <div
              key={sound.id}
              className="group flex items-center gap-2 bg-white/10 backdrop-blur-md rounded-full pl-3 pr-2 py-2 border border-white/20 hover:bg-white/20 transition-all"
            >
              <span className="text-lg">{sound.icon}</span>
              <span className="text-white text-sm">{sound.name}</span>
              <button
                onClick={() => onRemoveSound(sound.id)}
                className="w-6 h-6 rounded-full bg-white/20 hover:bg-white/30 flex items-center justify-center transition-all opacity-0 group-hover:opacity-100"
              >
                <X className="w-3 h-3 text-white" />
              </button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
