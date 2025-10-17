import { useTables } from "../hooks/useTable";
import { MdTableBar } from "react-icons/md";

interface Table {
  id: number;
  number: number;
  capacity: number;
  status: "available" | "occupied" | "reserved";
}

export const TablesUI = () => {
  const { data: tables, isLoading } = useTables();

  if (isLoading) {
    return <div className="text-[1.8rem] font-bold">Loading tables...</div>;
  }

  const getTableSize = (capacity: number) => {
    if (capacity >= 8) return "col-span-4 row-span-2"; // Large tables
    if (capacity >= 6) return "col-span-4 row-span-1"; // Wide tables
    if (capacity === 4) return "col-span-3 row-span-1"; // Medium tables
    return "col-span-2 row-span-1"; // Small tables
  };

  const getStatusColor = (status: string) => {
    switch (status.toLowerCase()) {
      case "occupied":
        return "text-red-500";
      case "reserved":
        return "text-yellow-500";
      case "available":
        return "text-green-500";
      default:
        return "text-gray-500";
    }
  };

  return (
    <div className="basis-9/12 mt-[2rem] border-2 border-gray-300 rounded-lg p-6 h-[45rem]">
      <div className="grid grid-cols-12 gap-8 w-full h-full p-6">
        {tables?.map((table: Table) => (
          <div
            key={table.id}
            className={`${getTableSize(table.capacity)}
            rounded-lg shadow-md p-4 flex flex-col items-center justify-center border-2 border-gray-200
            transition-all cursor-pointer hover:shadow-lg bg-white`}
          >
            <MdTableBar 
              className={`text-4xl mb-2 ${getStatusColor(table.status)}`}
            />
            <div className="text-xl font-semibold mb-2">
              Table {table.number}
            </div>
            <div className="text-gray-600">Capacity: {table.capacity}</div>
            <div className="mt-2 text-sm font-medium">
              {table.status.charAt(0).toUpperCase() + table.status.slice(1)}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
