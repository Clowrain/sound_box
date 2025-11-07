import { useState } from "react";
import { Timer, X } from "lucide-react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "./ui/dialog";
import { Button } from "./ui/button";

interface TimerDialogProps {
  onSetTimer: (minutes: number) => void;
  activeTimer: number | null;
  onCancelTimer: () => void;
}

export function TimerDialog({ onSetTimer, activeTimer, onCancelTimer }: TimerDialogProps) {
  const [isOpen, setIsOpen] = useState(false);
  const timerOptions = [5, 10, 15, 30, 45, 60, 90, 120];

  const handleSetTimer = (minutes: number) => {
    onSetTimer(minutes);
    setIsOpen(false);
  };

  return (
    <Dialog open={isOpen} onOpenChange={setIsOpen}>
      <DialogTrigger asChild>
        <Button
          variant="outline"
          size="lg"
          className="rounded-full h-14 w-14 bg-white/10 border-white/20 hover:bg-white/20 text-white relative"
        >
          <Timer className="w-5 h-5" />
          {activeTimer !== null && (
            <div className="absolute -top-1 -right-1 w-3 h-3 bg-green-500 rounded-full border-2 border-black" />
          )}
        </Button>
      </DialogTrigger>
      <DialogContent className="bg-black/95 border-white/20 text-white max-w-sm">
        <DialogHeader>
          <DialogTitle className="text-white">设置定时器</DialogTitle>
        </DialogHeader>
        
        <div className="grid grid-cols-3 gap-3 py-4">
          {timerOptions.map((minutes) => (
            <Button
              key={minutes}
              onClick={() => handleSetTimer(minutes)}
              variant="outline"
              className="h-16 rounded-xl bg-white/5 border-white/10 hover:bg-white/20 text-white"
            >
              <div className="flex flex-col items-center">
                <span className="text-xl">{minutes}</span>
                <span className="text-xs text-white/60">分钟</span>
              </div>
            </Button>
          ))}
        </div>

        {activeTimer !== null && (
          <div className="flex items-center justify-between p-3 bg-white/5 rounded-lg">
            <div className="flex items-center gap-2">
              <Timer className="w-4 h-4 text-green-500" />
              <span className="text-sm">定时器已设置: {activeTimer} 分钟</span>
            </div>
            <Button
              onClick={() => {
                onCancelTimer();
                setIsOpen(false);
              }}
              variant="ghost"
              size="icon"
              className="h-8 w-8 text-white/60 hover:text-white hover:bg-white/10"
            >
              <X className="w-4 h-4" />
            </Button>
          </div>
        )}
      </DialogContent>
    </Dialog>
  );
}
