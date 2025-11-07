import { Play, Pause, Timer } from "lucide-react";
import { Button } from "./ui/button";
import { TimerDialog } from "./TimerDialog";

interface PlayerControlProps {
  hasActiveSounds: boolean;
  isAnyPlaying: boolean;
  onPlayAll: () => void;
  onPauseAll: () => void;
  onSetTimer: (minutes: number) => void;
  activeTimer: number | null;
  onCancelTimer: () => void;
  remainingTime: number | null;
}

export function PlayerControl({ 
  hasActiveSounds, 
  isAnyPlaying, 
  onPlayAll, 
  onPauseAll,
  onSetTimer,
  activeTimer,
  onCancelTimer,
  remainingTime
}: PlayerControlProps) {
  if (!hasActiveSounds) return null;

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-gradient-to-t from-black/95 via-black/90 to-transparent backdrop-blur-lg p-6 pb-8">
      <div className="max-w-md mx-auto">
        {remainingTime !== null && (
          <div className="text-center mb-4">
            <div className="inline-flex items-center gap-2 bg-white/10 backdrop-blur-sm rounded-full px-4 py-2">
              <Timer className="w-4 h-4 text-white/70" />
              <span className="text-white">{formatTime(remainingTime)}</span>
            </div>
          </div>
        )}
        
        <div className="flex items-center justify-center gap-4">
          <TimerDialog 
            onSetTimer={onSetTimer}
            activeTimer={activeTimer}
            onCancelTimer={onCancelTimer}
          />
          
          <Button
            onClick={isAnyPlaying ? onPauseAll : onPlayAll}
            size="lg"
            className="rounded-full h-16 w-16 bg-white text-black hover:bg-white/90"
          >
            {isAnyPlaying ? (
              <Pause className="w-6 h-6 fill-current" />
            ) : (
              <Play className="w-6 h-6 fill-current ml-1" />
            )}
          </Button>
          
          <div className="w-14" /> {/* Spacer for symmetry */}
        </div>
      </div>
    </div>
  );
}
