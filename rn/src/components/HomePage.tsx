import { useState, useEffect, useRef } from "react";
import { Settings, Volume2, Moon } from "lucide-react";
import { Button } from "./ui/button";

interface HomePageProps {
  onNavigateToSounds: () => void;
}

export function HomePage({ onNavigateToSounds }: HomePageProps) {
  const [currentTime, setCurrentTime] = useState(new Date());
  const portraitDisplayRef = useRef<HTMLDivElement>(null);
  const landscapeDisplayRef = useRef<HTMLDivElement>(null);
  const [portraitDimensions, setPortraitDimensions] = useState({ cols: 20, rows: 16 });
  const [landscapeDimensions, setLandscapeDimensions] = useState({ cols: 24, rows: 12 });

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  // Measure container and calculate grid dimensions
  useEffect(() => {
    const calculateDimensions = () => {
      // Portrait
      if (portraitDisplayRef.current) {
        const width = portraitDisplayRef.current.offsetWidth;
        const height = portraitDisplayRef.current.offsetHeight;
        // Calculate optimal grid size based on container
        const dotSize = 8; // dot size + gap
        const cols = Math.floor(width / dotSize);
        const rows = Math.floor(height / dotSize);
        setPortraitDimensions({ cols: Math.max(cols, 20), rows: Math.max(rows, 12) });
      }

      // Landscape
      if (landscapeDisplayRef.current) {
        const width = landscapeDisplayRef.current.offsetWidth;
        const height = landscapeDisplayRef.current.offsetHeight;
        const dotSize = 8;
        const cols = Math.floor(width / dotSize);
        const rows = Math.floor(height / dotSize);
        setLandscapeDimensions({ cols: Math.max(cols, 24), rows: Math.max(rows, 10) });
      }
    };

    calculateDimensions();
    window.addEventListener('resize', calculateDimensions);
    
    // Use setTimeout to ensure layout is complete
    const timer = setTimeout(calculateDimensions, 100);

    return () => {
      window.removeEventListener('resize', calculateDimensions);
      clearTimeout(timer);
    };
  }, []);

  const formatTime = (date: Date) => {
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  };

  // Create dot matrix pattern for clock display
  const createClockPattern = () => {
    const time = formatTime(currentTime);
    const digits = time.split('');
    
    // Simplified 5x3 digit patterns
    const digitPatterns: { [key: string]: number[][] } = {
      '0': [[1,1,1], [1,0,1], [1,0,1], [1,0,1], [1,1,1]],
      '1': [[0,1,0], [1,1,0], [0,1,0], [0,1,0], [1,1,1]],
      '2': [[1,1,1], [0,0,1], [1,1,1], [1,0,0], [1,1,1]],
      '3': [[1,1,1], [0,0,1], [1,1,1], [0,0,1], [1,1,1]],
      '4': [[1,0,1], [1,0,1], [1,1,1], [0,0,1], [0,0,1]],
      '5': [[1,1,1], [1,0,0], [1,1,1], [0,0,1], [1,1,1]],
      '6': [[1,1,1], [1,0,0], [1,1,1], [1,0,1], [1,1,1]],
      '7': [[1,1,1], [0,0,1], [0,0,1], [0,0,1], [0,0,1]],
      '8': [[1,1,1], [1,0,1], [1,1,1], [1,0,1], [1,1,1]],
      '9': [[1,1,1], [1,0,1], [1,1,1], [0,0,1], [1,1,1]],
      ':': [[0,0,0], [0,1,0], [0,0,0], [0,1,0], [0,0,0]],
    };

    return digits.map(digit => digitPatterns[digit] || digitPatterns['0']);
  };

  const patterns = createClockPattern();

  return (
    <div className="fixed inset-0 bg-gradient-to-br from-slate-800 via-slate-700 to-slate-800 overflow-hidden">
      {/* Main content - responsive to orientation */}
      <div className="h-screen w-screen flex items-center justify-center p-4 md:p-8">
        {/* Radio-style container */}
        <div className="relative bg-gradient-to-b from-slate-600 to-slate-700 rounded-3xl shadow-2xl p-6 md:p-8 w-full h-full landscape:max-w-4xl landscape:max-h-[500px] portrait:max-w-md portrait:max-h-[90vh]">
          {/* Portrait layout */}
          <div className="h-full flex flex-col landscape:hidden">
            {/* Top controls */}
            <div className="flex justify-between items-start mb-6">
              <div className="w-12 h-16 bg-slate-800/50 rounded-lg border-2 border-slate-900/50 flex items-center justify-center">
                <Moon className="w-6 h-6 text-slate-400" />
              </div>
              <div className="text-right">
                <div className="text-xs text-slate-400 mb-1">白噪音收音机</div>
                <div className="text-sm text-slate-300">v=1.0</div>
              </div>
            </div>

            {/* Main display area with dot matrix */}
            <div ref={portraitDisplayRef} className="relative bg-slate-700 rounded-2xl p-6 mb-6 border-4 border-slate-800/50 shadow-inner">
              {/* Dot matrix grid */}
              <div className="grid gap-1.5" style={{ gridTemplateColumns: `repeat(${portraitDimensions.cols}, minmax(0, 1fr))` }}>
                {Array.from({ length: portraitDimensions.rows }).map((_, rowIndex) => (
                  Array.from({ length: portraitDimensions.cols }).map((_, colIndex) => {
                    // Calculate if this dot should be lit for the clock display
                    let isLit = false;
                    
                    // Calculate total width needed for time display
                    const totalDigitWidth = patterns.reduce((sum, pattern) => sum + pattern[0].length + 1, -1);
                    const scale = Math.min(Math.floor(portraitDimensions.cols / totalDigitWidth), 3);
                    const scaledWidth = totalDigitWidth * scale;
                    const startCol = Math.floor((portraitDimensions.cols - scaledWidth) / 2);
                    const digitHeight = 5;
                    const scaledHeight = digitHeight * scale;
                    const startRow = Math.floor((portraitDimensions.rows - scaledHeight) / 2);
                    
                    // Check if we're in the time display area
                    if (rowIndex >= startRow && rowIndex < startRow + scaledHeight) {
                      const digitRow = Math.floor((rowIndex - startRow) / scale);
                      let currentCol = startCol;
                      
                      for (let i = 0; i < patterns.length; i++) {
                        const pattern = patterns[i];
                        const digitWidth = pattern[0].length;
                        const scaledDigitWidth = digitWidth * scale;
                        
                        if (colIndex >= currentCol && colIndex < currentCol + scaledDigitWidth) {
                          const digitCol = Math.floor((colIndex - currentCol) / scale);
                          isLit = pattern[digitRow]?.[digitCol] === 1;
                          break;
                        }
                        currentCol += scaledDigitWidth + scale; // Add scaled spacing
                      }
                    }
                    
                    return (
                      <div
                        key={`${rowIndex}-${colIndex}`}
                        className={`aspect-square rounded-full transition-all duration-300 ${
                          isLit 
                            ? 'bg-amber-400 shadow-lg shadow-amber-400/50' 
                            : 'bg-slate-800/50'
                        }`}
                      />
                    );
                  })
                ))}
              </div>
            </div>

            {/* Control buttons */}
            <div className="grid grid-cols-2 gap-4 flex-1">
              <Button
                onClick={onNavigateToSounds}
                className="bg-slate-800 hover:bg-slate-750 border-2 border-slate-900/50 rounded-xl shadow-lg flex items-center justify-center gap-2"
              >
                <Volume2 className="w-5 h-5 text-slate-300" />
                <span className="text-slate-200">音效</span>
              </Button>
              
              <Button
                onClick={onNavigateToSounds}
                className="bg-slate-800 hover:bg-slate-750 border-2 border-slate-900/50 rounded-xl shadow-lg flex items-center justify-center gap-2"
              >
                <Settings className="w-5 h-5 text-slate-300" />
                <span className="text-slate-200">设置</span>
              </Button>
              
              <Button
                className="bg-slate-800 hover:bg-slate-750 border-2 border-slate-900/50 rounded-xl shadow-lg flex items-center justify-center"
              >
                <span className="text-3xl">🌧️</span>
              </Button>
              
              <Button
                className="bg-slate-800 hover:bg-slate-750 border-2 border-slate-900/50 rounded-xl shadow-lg flex items-center justify-center"
              >
                <span className="text-3xl">🔥</span>
              </Button>
              
              <Button
                className="bg-slate-800 hover:bg-slate-750 border-2 border-slate-900/50 rounded-xl shadow-lg flex items-center justify-center"
              >
                <span className="text-3xl">⚡</span>
              </Button>
              
              <Button
                className="bg-slate-800 hover:bg-slate-750 border-2 border-slate-900/50 rounded-xl shadow-lg flex items-center justify-center"
              >
                <span className="text-3xl">🌊</span>
              </Button>
            </div>

            {/* Bottom text */}
            <div className="text-center mt-4 text-slate-400 text-xs">
              白噪音 · 放松身心 · 专注睡眠
            </div>
          </div>

          {/* Landscape layout */}
          <div className="h-full hidden landscape:flex items-stretch gap-6">
            {/* Left control panel */}
            <div className="flex flex-col justify-between py-2">
              <div className="w-12 h-16 bg-slate-800/50 rounded-lg border-2 border-slate-900/50 flex items-center justify-center">
                <Moon className="w-6 h-6 text-slate-400" />
              </div>
              
              <Button
                onClick={onNavigateToSounds}
                className="w-16 h-16 bg-slate-800 hover:bg-slate-750 border-2 border-slate-900/50 rounded-xl shadow-lg flex items-center justify-center"
              >
                <Volume2 className="w-6 h-6 text-slate-300" />
              </Button>

              <div className="w-12 h-16 bg-slate-800/50 rounded-lg border-2 border-slate-900/50 flex items-center justify-center">
                <div className="text-2xl">⚙️</div>
              </div>
            </div>

            {/* Main display area with dot matrix */}
            <div className="flex-1 flex flex-col justify-center">
              <div className="text-center mb-4">
                <div className="text-xs text-slate-400 mb-1">白噪音收音机</div>
                <div className="text-sm text-slate-300">v=1.0</div>
              </div>
              
              <div ref={landscapeDisplayRef} className="relative bg-slate-700 rounded-2xl p-6 border-4 border-slate-800/50 shadow-inner">
                {/* Dot matrix grid - wider for landscape */}
                <div className="grid gap-1.5" style={{ gridTemplateColumns: `repeat(${landscapeDimensions.cols}, minmax(0, 1fr))` }}>
                  {Array.from({ length: landscapeDimensions.rows }).map((_, rowIndex) => (
                    Array.from({ length: landscapeDimensions.cols }).map((_, colIndex) => {
                      // Calculate if this dot should be lit for the clock display
                      let isLit = false;
                      
                      // Calculate total width needed for time display
                      const totalDigitWidth = patterns.reduce((sum, pattern) => sum + pattern[0].length + 1, -1);
                      const scale = Math.min(Math.floor(landscapeDimensions.cols / totalDigitWidth), 4);
                      const scaledWidth = totalDigitWidth * scale;
                      const startCol = Math.floor((landscapeDimensions.cols - scaledWidth) / 2);
                      const digitHeight = 5;
                      const scaledHeight = digitHeight * scale;
                      const startRow = Math.floor((landscapeDimensions.rows - scaledHeight) / 2);
                      
                      // Check if we're in the time display area
                      if (rowIndex >= startRow && rowIndex < startRow + scaledHeight) {
                        const digitRow = Math.floor((rowIndex - startRow) / scale);
                        let currentCol = startCol;
                        
                        for (let i = 0; i < patterns.length; i++) {
                          const pattern = patterns[i];
                          const digitWidth = pattern[0].length;
                          const scaledDigitWidth = digitWidth * scale;
                          
                          if (colIndex >= currentCol && colIndex < currentCol + scaledDigitWidth) {
                            const digitCol = Math.floor((colIndex - currentCol) / scale);
                            isLit = pattern[digitRow]?.[digitCol] === 1;
                            break;
                          }
                          currentCol += scaledDigitWidth + scale; // Add scaled spacing
                        }
                      }
                      
                      return (
                        <div
                          key={`${rowIndex}-${colIndex}`}
                          className={`aspect-square rounded-full transition-all duration-300 ${
                            isLit 
                              ? 'bg-amber-400 shadow-lg shadow-amber-400/50' 
                              : 'bg-slate-800/50'
                          }`}
                        />
                      );
                    })
                  ))}
                </div>
              </div>

              <div className="text-center mt-4 text-slate-400 text-xs">
                白噪音 · 放松身心 · 专注睡眠
              </div>
            </div>

            {/* Right button grid */}
            <div className="grid grid-cols-2 gap-3 content-center">
              <Button
                onClick={onNavigateToSounds}
                className="w-20 h-20 bg-slate-800 hover:bg-slate-750 border-2 border-slate-900/50 rounded-xl shadow-lg flex items-center justify-center"
              >
                <span className="text-3xl">🌧️</span>
              </Button>
              
              <Button
                className="w-20 h-20 bg-slate-800 hover:bg-slate-750 border-2 border-slate-900/50 rounded-xl shadow-lg flex items-center justify-center"
              >
                <span className="text-3xl">🔥</span>
              </Button>
              
              <Button
                className="w-20 h-20 bg-slate-800 hover:bg-slate-750 border-2 border-slate-900/50 rounded-xl shadow-lg flex items-center justify-center"
              >
                <span className="text-3xl">⚡</span>
              </Button>
              
              <Button
                className="w-20 h-20 bg-slate-800 hover:bg-slate-750 border-2 border-slate-900/50 rounded-xl shadow-lg flex items-center justify-center"
              >
                <span className="text-3xl">🌊</span>
              </Button>
              
              <Button
                onClick={onNavigateToSounds}
                className="w-20 h-20 bg-slate-800 hover:bg-slate-750 border-2 border-slate-900/50 rounded-xl shadow-lg flex items-center justify-center"
              >
                <Settings className="w-6 h-6 text-slate-300" />
              </Button>
              
              <Button
                className="w-20 h-20 bg-slate-800 hover:bg-slate-750 border-2 border-slate-900/50 rounded-xl shadow-lg flex items-center justify-center"
              >
                <span className="text-3xl">🌲</span>
              </Button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
