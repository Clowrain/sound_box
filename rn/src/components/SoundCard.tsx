import { Menu } from "lucide-react";
import { Slider } from "./ui/slider";

export interface Sound {
  id: string;
  name: string;
  icon: string;
  audio?: HTMLAudioElement;
}

interface SoundCardProps {
  sound: Sound;
  volume: number;
  isPlaying: boolean;
  onVolumeChange: (value: number) => void;
  onToggle: () => void;
}

export function SoundCard({ sound, volume, isPlaying, onVolumeChange, onToggle }: SoundCardProps) {
  return (
    <div 
      className={`bg-white/5 backdrop-blur-sm rounded-2xl transition-all duration-300 ${
        isPlaying ? 'bg-white/10 ring-1 ring-white/20' : ''
      }`}
      onClick={onToggle}
    >
      <div className="flex items-center gap-4 p-4">
        <div className="text-2xl flex-shrink-0">{sound.icon}</div>
        
        <div className="flex-1 min-w-0">
          <h3 className="text-white">{sound.name}</h3>
          
          {isPlaying && (
            <div 
              className="flex items-center gap-2 mt-2"
              onClick={(e) => e.stopPropagation()}
            >
              <Slider
                value={[volume]}
                onValueChange={(values) => onVolumeChange(values[0])}
                max={100}
                step={1}
                className="flex-1"
              />
              <span className="text-white/60 text-xs w-8 text-right">{volume}</span>
            </div>
          )}
        </div>
        
        <Menu className="w-5 h-5 text-white/40 flex-shrink-0" />
      </div>
    </div>
  );
}
