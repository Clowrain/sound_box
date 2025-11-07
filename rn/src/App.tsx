import { useState } from "react";
import { HomePage } from "./components/HomePage";
import { SoundsPage } from "./components/SoundsPage";

type Page = "home" | "sounds";

export default function App() {
  const [currentPage, setCurrentPage] = useState<Page>("home");

  return (
    <>
      {currentPage === "home" && (
        <HomePage onNavigateToSounds={() => setCurrentPage("sounds")} />
      )}
      {currentPage === "sounds" && (
        <SoundsPage onBack={() => setCurrentPage("home")} />
      )}
    </>
  );
}
